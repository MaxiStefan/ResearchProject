#!/bin/bash
for experimentIteration in 1 #2 3 4 5 6 7 8 9 10
do
    echo "Experiment iteration number $experimentIteration"
    treatments[0]="ALL"
    treatments[1]="IDLE"
    treatments[2]="UP_IDLE"
    treatments[3]="FIBO_MATRIX"
    treatments[4]="BUBBLE_COLLATZ"

    echo "Treatments available ${treatments[@]}"

    for treatmentIteration in 1 2 3 4 5
    do    
        echo "Treatment iteration number $treatmentIteration"
        size=${#treatments[@]}
        index=$(($RANDOM % $size))
        treatment=${treatments[$index]}
        echo "Selected treatment $treatment"

        sleep 1

        if [ "$treatment" = "BUBBLE_COLLATZ" ]; then
            echo "Starting bubble"
            echo "Starting collatz"
        elif [ "$treatment" = "FIBO_MATRIX" ]; then
            echo "Starting fibo"
            echo "Starting matrix"
        fi


        unset treatments[index]
        for i in "${!treatments[@]}"
        do
            new_treatments+=( "${treatments[i]}" )
        done
        treatments=("${new_treatments[@]}")
        unset new_treatments

        echo -e "Remainder treatments ${treatments[@]} \n"
        mkdir -p "Experiment_Iteration_1$experimentIteration/$treatment"

        sleep 1

    done 
    sleep 2
done
