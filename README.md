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

Test Call Api -> Result (Number of Errors:	0)
=======
``` sh
go-wrk -c 5 -d 30 http://localhost:3001/apis/
Running 30s test @ http://localhost:3001/apis/
5 goroutine(s) running concurrently
344064 requests in 29.920196008s, 69.23MB read
Requests/sec:		11499.39
Transfer/sec:		2.31MB
Avg Req Time:		434.805µs
Fastest Request:	163.167µs
Slowest Request:	11.768541ms
Number of Errors:	0
```

