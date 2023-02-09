#!/bin/bash
treatments[0]="ALL"
treatments[1]="UP_IDLE"
treatments[2]="IDLE"
treatments[3]="FIBO_MATRIX"
treatments[4]="BUBBLE_COLLATZ"
SudoPassword=maximus

for i in 1 2 3 4 5 6 7 8 9 10
do
    for treatment in ${$treatments[@]}
    do
        cd Experiment_Iteration_$i/$treatment/powerapi
        echo $SudoPassword | sudo -S rm -rf .local .cache
        cd ..; cd ..; cd ..;
    done
done