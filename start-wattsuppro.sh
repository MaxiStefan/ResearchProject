#!/bin/bash
TreatmentTaskDuration=$(($(head -n 1 ./Containers/.env | tail -1 | cut -d '=' -f 2) * 60))
TreatmentTimeout=$(($(head -n 2 ./Containers/.env | tail -1 | cut -d '=' -f 2) * 60))
LogsExtractionTimeout=$(head -n 3 ./Containers/.env | tail -1 | cut -d '=' -f 2)
ServiceStartTimeout=$(head -n 4 ./Containers/.env | tail -1 | cut -d '=' -f 2)
SudoPassword=$(echo $(head -n 5 ./Containers/.env | tail -1 | cut -d '=' -f 2))

LoggerDuration=$(( ($TreatmentTaskDuration + $TreatmentTimeout + $LogsExtractionTimeout + $ServiceStartTimeout ) * 5 * 10 + 5 ))

echo $SudoPassword | sudo -S python3 ../wattsuppro_logger/WattsupPro.py -l -o gl3.log -p /dev/ttyUSB2 -t $LoggerDuration > /dev/null 2>&1 &
echo $SudoPassword | sudo -S python3 ../wattsuppro_logger/WattsupPro.py -l -o gl4.log -p /dev/ttyUSB1 -t $LoggerDuration > /dev/null 2>&1 &