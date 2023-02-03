#!/bin/sh

SudoPassword=maximus

echo "Restarting docker service"
echo $SudoPassword | sudo -S systemctl stop docker
echo $SudoPassword | sudo -S systemctl start docker

echo "Bringing the system up"
echo $SudoPassword | sudo -S docker compose up

echo "Waiting for services to start"
sleep 5
echo "Services started."

echo "Starting fibonacci sequence..."
curl localhost:1055/start > /dev/null 2>&1 &
echo "Starting matrix multiplication..."
curl localhost:1056/start > /dev/null 2>&1 &
echo "Starting bubble sort..."
curl localhost:1057/start > /dev/null 2>&1 &
echo "Starting collatz conjecture..."
curl localhost:1058/start > /dev/null 2>&1 &

echo "Started experiment at $(date "+%T")"

echo "Waiting $(cat .env | cut -d '=' -f 2) minutes for the benchmark to finish"
ExperimentDuration=$(($(cat .env | cut -d '=' -f 2) * 60))
sleep $ExperimentDuration

echo "Extracting power reports"
echo $SudoPassword | sudo -S docker exec -it researchproject-power-api-smartwatts-1 bash -C "cd ..; chmod -R 777 powerapi/;exit;"
echo $SudoPassword | sudo -S docker cp researchproject-power-api-smartwatts-1:/opt/powerapi /home/maxi/Desktop/Work/ResearchProject

echo "Waiting for the extraction to be complete"
sleep 5

cd powerapi/
rm -rf .bash_history .bash_logout .cache .local .bashrc .profile
cd ..

echo "Stopped experiment at $(date "+%T")"

echo "Bringing system down"
#Bring system down
echo $SudoPassword | sudo -S docker compose down
echo $SudoPassword | sudo -S systemctl stop docker

#Clean cgroups
# sudo cgdelete perf_event:matrix
# sudo cgdelete perf_event:bubblesort
# sudo cgdelete perf_event:collatz
# sudo cgdelete perf_event:fibonacci
echo $SudoPassword | sudo -S cgdelete perf_event:docker
