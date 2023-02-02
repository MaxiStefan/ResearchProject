#!/bin/sh

if ls /sys/fs/cgroup/perf_event | grep -q fibonacci; then
 echo "fibonacci exists. adding pid $(sudo docker inspect -f '{{.State.Pid}}' fibonacci)";
 sudo cgclassify -g perf_event:fibonacci $(sudo docker inspect -f '{{.State.Pid}}' fibonacci);
 sudo cgcreate -g perf_event:fibonacci; echo "created fibonacci cgroup";
fi

if ls /sys/fs/cgroup/perf_event | grep -q collatz; then
 echo "collatz exists. adding pid $(sudo docker inspect -f '{{.State.Pid}}' collatz)";
 sudo cgclassify -g perf_event:collatz $(sudo docker inspect -f '{{.State.Pid}}' collatz);
 sudo cgcreate -g perf_event:collatz; echo "created collatz cgroup";
fi

if ls /sys/fs/cgroup/perf_event | grep -q matrix; then
 echo "matrix exists. adding pid $(sudo docker inspect -f '{{.State.Pid}}' matrix)";
 sudo cgclassify -g perf_event:matrix $(sudo docker inspect -f '{{.State.Pid}}' matrix);
 sudo cgcreate -g perf_event:matrix; echo "created matrix cgroup";
fi

if ls /sys/fs/cgroup/perf_event | grep -q bubblesort; then
 echo "bubblesort exists. adding pid $(sudo docker inspect -f '{{.State.Pid}}' bubblesort)";
 sudo cgclassify -g perf_event:bubblesort $(sudo docker inspect -f '{{.State.Pid}}' bubblesort);
 sudo cgcreate -g perf_event:bubblesort; echo "created bubblesort cgroup";
fi
