#!/bin/sh

echo "Restarting docker service"
sudo systemctl stop docker
sudo systemctl start docker

echo "Bringing the system up"
sudo docker compose up

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

echo "Waiting $(cat .env | cut -d '=' -f 2) minutes for the benchmark to finish"
sleep $(cat .env | cut -d '=' -f 2)

echo "Extracting power reports"
sudo docker exec -it researchproject-power-api-smartwatts-1 bash
cd ..
chmod -R 777 powerapi/
sleep 5
exit
sudo docker cp researchproject-power-api-smartwatts-1:/opt/powerapi /home/maxi/Desktop/Work/ResearchProject

echo "Waiting for the extraction to be complete"
sleep 5

cd powerapi/
rm -rf .bash_history .bash_logout .cache .local .bashrc .profile
cd ..

#Clean cgroups
# sudo cgdelete perf_event:matrix
# sudo cgdelete perf_event:bubblesort
# sudo cgdelete perf_event:collatz
# sudo cgdelete perf_event:fibonacci
# sudo cgdelete perf_event:docker

#Restart docker service
sudo docker compose down
sudo systemctl stop docker
