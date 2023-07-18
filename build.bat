docker build -t openedge-compiler:12.7 -t devbfvio/openedge-compiler:12.7.0 -t devbfvio/openedge-compiler:latest -t openedge-compiler:latest .
rem remove intermediate containers
docker image prune -f

