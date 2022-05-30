del ./output
del ./delta

docker kill $(docker ps -a -q)
docker rmi $(docker images -a -q) -f

docker-compose up



