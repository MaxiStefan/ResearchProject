#!/bin/bash
TreatmentTaskDuration=$(($(head -n 1 ./Containers/.env | tail -1 | cut -d '=' -f 2) * 60))
TreatmentTimeout=$(($(head -n 2 ./Containers/.env | tail -1 | cut -d '=' -f 2) * 60))
LogsExtractionTimeout=$(head -n 3 ./Containers/.env | tail -1 | cut -d '=' -f 2)
ServiceStartTimeout=$(head -n 4 ./Containers/.env | tail -1 | cut -d '=' -f 2)
SudoPassword=$(echo $(head -n 5 ./Containers/.env | tail -1 | cut -d '=' -f 2))
ResidualLoggingTime=18000
TreatmentCount=5
ExperimentIterations=10
LoggerDuration=$(( ($TreatmentTaskDuration + $TreatmentTimeout + $LogsExtractionTimeout + $LogsExtractionTimeout + $ServiceStartTimeout ) * $TreatmentCount * $ExperimentIterations + $ResidualLoggingTime ))
#LoggerDuration=120

echo "Started logging at $(date "+%T.%6N")"

echo $SudoPassword | sudo -S python3 ../wattsuppro_logger/WattsupPro.py -l -o gl3.log -p /dev/ttyUSB2 -t $LoggerDuration > /dev/null 2>&1 &

sleep $LoggerDuration

echo "Stopped logging at $(date "+%T.%6N")"
