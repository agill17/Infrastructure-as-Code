

### swarm visualizer
docker run -it -dp 8080:8080 -v /var/run/docker.sock:/var/run/docker.sock dockersamples/visualizer
echo "started swarm viusalizer"
echo "-----------------------------------------------------------"



####################### Networks ######################


docker network create --driver overlay backend
echo "created backend overlay network"
echo "-----------------------------------------------------------"


docker network create --driver overlay frontend
echo "created frontend overlay network"
echo "-----------------------------------------------------------"



####################### Services ######################

### vote:
docker service create -dp 8081:80 --name vote --network frontend --replicas 3 dockersamples/examplevotingapp_vote:before
echo "created vote service."
echo "-----------------------------------------------------------"

### redis:
docker service create -d --name redis --network frontend --replicas 2 redis:3.2
echo "created redis service."
echo "-----------------------------------------------------------"

### worker:
docker service create -d --name worker --network frontend --network backend dockersamples/examplevotingapp_worker
echo "created worker service."
echo "-----------------------------------------------------------"

### db:
docker service create -d --name db --network backend -e POSTGRES_PASSWORD=pass --mount type=volume,source=db-data,target=/var/lib/postgresql/data postgres:9.4
echo "created db service."
echo "-----------------------------------------------------------"

### result:
docker service create -d --name result --network backend --publish 5001:80 dockersamples/examplevotingapp_result:before
echo "created result service."
echo "-----------------------------------------------------------"


docker service ls

echo "Exit status: $?"
