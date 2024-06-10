reload_nginx() {
  docker exec $1 /usr/sbin/nginx -s reload
  sleep 1
}

remove_container() {
  docker stop $1 > /dev/null
  docker rm $1 > /dev/null
}

zero_downtime_deploy() {
  nginx=$1
  service_name=$2
  service_scale=$3
  service_port=$4

  old_container_id=$(docker compose ps $service_name -q)

  is_have_old_container=0

  if [ -n "$old_container_id" ]; then
      is_have_old_container=1
      number_of_containers=$(echo "$old_container_id" | wc -l)
      number_of_containers_to_scale=$((number_of_containers + service_scale))
  else
      echo "No old container IDs found. Please run deploy script"
  fi

  echo "Number of container IDs to scale: $number_of_containers_to_scale"

  if [ $is_have_old_container == 0 ]; then
     docker compose up -d --no-deps --scale $service_name=$service_scale --no-recreate $service_name
  else
      # Manage new container

       # bring a new container online, running new code
       # (nginx continues routing to the old container only)
       docker compose up -d --no-deps --scale $service_name=$number_of_containers_to_scale --no-recreate $service_name

       new_container_id=$(docker compose ps $service_name -q | grep -v "$old_container_id")

       # Split the string into a list of strings
       new_container_id_list=($new_container_id)

       # Convert the list of strings into a bash array
       new_container_id_array=("${new_container_id_list[@]}")

       # Wait for new container to be available by loop new_container_id_array
       for id in "${new_container_id_array[@]}"; do
         new_container_ip=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $id)
         docker exec $nginx curl --silent --include --retry-connrefused --retry 30 --retry-delay 1 --fail http://$new_container_ip:$service_port > /dev/null || { remove_container "$id"; exit 1; }
       done


       # Manage old container

       # start routing requests to the new container (as well as the old)
       reload_nginx $nginx

       # Split the string into a list of strings
       old_container_id_list=($old_container_id)

       # Convert the list of strings into a bash array
       old_container_id_array=("${old_container_id_list[@]}")

       # take the old container offline
       for id in "${old_container_id_array[@]}"; do
         remove_container $id
       done

       docker compose up -d --no-deps --scale $service_name=$service_scale --no-recreate $service_name
  fi

  reload_nginx $nginx

}
