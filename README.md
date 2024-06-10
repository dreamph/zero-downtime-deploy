# Zero Downtime Deploy

Install Tools
=======
``` sh
go install github.com/go-task/task/v3/cmd/task@latest
go install github.com/tsliwowicz/go-wrk@latest
```

Build
=======
``` sh
cd sourcecode/zrdt
docker compose -f docker-compose.build.yml build
```

Deploy
=======
``` sh
cd app/zrdt
task deploy
```

Test Call Api
=======
``` sh
go-wrk -c 5 -d 30 http://localhost:3001/apis/
```

ReDeploy Again
=======
``` sh
cd app/zrdt
task deploy
```