#!/bin/bash
TreatmentTimeout=2
SudoPassword=maximus

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
        echo $SudoPassword | sudo -S docker compose up -d
        if [ "$treatment" != "IDLE" ]; then
            cd Containers/
            echo $SudoPassword | sudo -S docker compose up -d
            cd ..
        fi

        echo "Waiting for services to start"
        sleep 5
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

        echo "Started treatment at $(date "+%T")"

        echo "Waiting $(cat ./SmartWatts/.env | cut -d '=' -f 2) minutes for the benchmark to finish"
        TreatmentDuration=$(($(cat ./SmartWatts/.env | cut -d '=' -f 2) * 60))
        sleep $TreatmentDuration

        #After the TreatmentDuration extract the SmartWatts readings using docker cp
        echo "Extracting power reports"
        echo $SudoPassword | sudo -S docker exec -it researchproject-power-api-smartwatts-1 bash -C "cd ..; chmod -R 777 powerapi/;exit;"
        echo $SudoPassword | sudo -S docker cp researchproject-power-api-smartwatts-1:/opt/powerapi /home/maxi/Desktop/Work/ResearchProject/$experimentIteration/$treatment

        echo "Waiting for the extraction to be complete"
        sleep 5

        #Remove unnecessary files
        # cd powerapi/$experimentIteration/$treatment/
        rm -rf powerapi/$experimentIteration/$treatment/.bash_history  powerapi/$experimentIteration/$treatment/.bash_logout powerapi/$experimentIteration/$treatment/.cache powerapi/$experimentIteration/$treatment/.local powerapi/$experimentIteration/$treatment/.bashrc powerapi/$experimentIteration/$treatment/.profile
        # cd ..

        echo "Stopped treatment at $(date "+%T")"

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

    done
done
