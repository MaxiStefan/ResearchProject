#!/bin/bash
SudoPassword=maximus
#Bring down SmartWatts
cd SmartWatts/
echo $SudoPassword | sudo -S docker compose down
cd ..

#Bring down the containers
cd Containers/
echo $SudoPassword | sudo -S docker compose down
cd ..

#Restart docker and the cgroups
echo $SudoPassword | sudo -S systemctl stop docker
echo $SudoPassword | sudo -S cgdelete perf_event:docker
