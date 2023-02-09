#!/bin/bash
TreatmentTaskDuration=$(($(head -n 1 ./Containers/.env | tail -1 | cut -d '=' -f 2) * 60))
TreatmentTimeout=$(($(head -n 2 ./Containers/.env | tail -1 | cut -d '=' -f 2) * 60))
LogsExtractionTimeout=$(head -n 3 ./Containers/.env | tail -1 | cut -d '=' -f 2)
ServiceStartTimeout=$(head -n 4 ./Containers/.env | tail -1 | cut -d '=' -f 2)
SudoPassword=$(head -n 5 ./Containers/.env | tail -1 | cut -d '=' -f 2)

for experimentIteration in  1 2 3 4 5 6 7 8 9 10
do
    #Creating the treatment array
    treatments[0]="ALL"
    treatments[1]="IDLE"
    treatments[2]="UP_IDLE"
    treatments[3]="FIBO_MATRIX"
    treatments[4]="BUBBLE_COLLATZ"

    for treatmentIteration in 1 2 3 4 5
    do
        #Randomly select a treatment
        size=${#treatments[@]}
        index=$(($RANDOM % $size))
        treatment=${treatments[$index]}
        echo "Selected treatment $treatment"

        echo "Restarting docker service"
        echo $SudoPassword | sudo -S systemctl stop docker
        echo $SudoPassword | sudo -S systemctl start docker

        echo "Bringing the system up"
        cd SmartWatts/ 
        echo $SudoPassword | sudo -S docker compose up -d
        cd ..
        if [ "$treatment" != "IDLE" ]; then
            cd Containers/
            echo $SudoPassword | sudo -S docker compose up -d
            cd ..
        fi

        echo "Waiting for services to start"
        sleep $ServiceStartTimeout
        echo "Services started."

        #If the treatment is BUBBLE_COLLATZ or FIBO_MATRIX start their tasks
        if [ "$treatment" = "BUBBLE_COLLATZ" ]; then
            echo "Starting bubble sort..."
            curl localhost:1057/start > /dev/null 2>&1 &
            echo "Starting collatz conjecture..."
            curl localhost:1058/start > /dev/null 2>&1 &
        elif [ "$treatment" = "FIBO_MATRIX" ]; then
            echo "Starting fibonacci sequence..."
            curl localhost:1055/start > /dev/null 2>&1 &
            echo "Starting matrix multiplication..."
            curl localhost:1056/start > /dev/null 2>&1 &
        elif [ "$treatment" = "ALL" ]; then        
            echo "Starting fibonacci sequence..."
            curl localhost:1055/start > /dev/null 2>&1 &
            echo "Starting matrix multiplication..."
            curl localhost:1056/start > /dev/null 2>&1 &
            echo "Starting bubble sort..."
            curl localhost:1057/start > /dev/null 2>&1 &
            echo "Starting collatz conjecture..."
            curl localhost:1058/start > /dev/null 2>&1 &
        fi

        treatmentStartTime=$(date "+%T.%6N")
        echo "Started $treatment at $treatmentStartTime"
        echo "Waiting for the benchmark to finish"
        sleep $TreatmentTaskDuration

        #After the TreatmentTaskDuration extract the SmartWatts readings using docker cp
        echo "Extracting power reports"
        mkdir -p "Experiment_Iteration_$experimentIteration/$treatment"
        echo $SudoPassword | sudo -S docker exec -it smartwatts-power-api-smartwatts-1 bash -C "cd ..; chmod -R 777 powerapi/;exit;"
        echo $SudoPassword | sudo -S docker cp smartwatts-power-api-smartwatts-1:/opt/powerapi $(pwd)/Experiment_Iteration_$experimentIteration/$treatment

        echo "Waiting for the extraction to be complete"
        sleep $LogsExtractionTimeout

        treatmentStopTime=$(date "+%T.%6N")
        echo "Stopped $treatment at $treatmentStopTime"
        echo "$experimentIteration,$treatment,$treatmentStartTime,$treatmentStopTime" >> experiment_log.csv

        echo "Bringing system down"
        #Bring system down
        cd SmartWatts/
        echo $SudoPassword | sudo -S docker compose down
        cd ..
        if [ "$treatment" != "IDLE" ]; then
            cd Containers/
            echo $SudoPassword | sudo -S docker compose down
            cd ..
        fi
        echo $SudoPassword | sudo -S systemctl stop docker

        #Clean cgroups
        # sudo cgdelete perf_event:matrix
        # sudo cgdelete perf_event:bubblesort
        # sudo cgdelete perf_event:collatz
        # sudo cgdelete perf_event:fibonacci
        echo $SudoPassword | sudo -S cgdelete perf_event:docker

        #Remove the selected treatment from the array
        unset treatments[index]

        #Reassign the array with the remainder treatments to avoid indexation errors
        for i in "${!treatments[@]}"
        do
            new_treatments+=( "${treatments[i]}" )
        done
        treatments=("${new_treatments[@]}")
        
        #Discard temporary array
        unset new_treatments

        echo -e "Remainder treatments ${treatments[@]} \n"

        echo -e "Taking the treatment timeout \n"
        sleep $TreatmentTimeout

    done
done

sh ./clean-files.sh
