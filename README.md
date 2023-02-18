#An independent assessment of the accuracy of SmartWatts in the context of Docker-based microservices

###Configure SmartWatts
Run the sw_autoconfig.sh script to configure SmartWatts

###Start Watts Up Pro profiler
Run the start-wattsup_pro_glx.sh script to start the Watts Up Pro profiler. The script can be changed to listen to a specific port, output a named log file and to profiler for a specific amount of time.

###Start SmartWatts benchmarking
Run the start-experiment.sh to start the benchmarking of the microservices using SmartWatts. All the configurable variables can be found in the /Containers/.env file. If the script is interrupted, you can clean everything up with the emergency-cleanup.sh script.

###Linux Cgroups
Run ls /sys/fs/cgroup command in the terminal to determine the architecture of the CGroup version the machine is running. If perf_event cgroup is not available at the previous path, run grep cgroup /proc/filesystems to determine the CGroup version. Mounting the perf_event cgroup may be necessary.

If the machine has CGroupV2 and CGroupV1, you need to configure Docker to run using the cgroupfs driver. To do so, perform the following actions:
- Docker config
```bash
$ systemctl status docker
#Check following section 
Loaded: loaded (/usr/lib/systemd/system/docker.service; enabled; vendor preset: disabled)

$ sudo mkdir -p /etc/systemd/system/docker.service.d
$ sudo nano /etc/systemd/system/docker.service.d/override.conf
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock --exec-opt native.cgroupdriver=cgroupfs

#Restart the Docker service by running the following command:
$ systemctl daemon-reload
$ systemctl restart docker

# Verify the cgroups driver to systemd
$ docker info
```

- Grub config

```bash
#Make sure systemd.unified_cgroup_hierarchy=0 is added in /etc/default/grub
$ cat /etc/default/grub
$ nano /etc/default/grub
GRUB_CMDLINE_LINUX_DEFAULT="systemd.unified_cgroup_hierarchy=0"

$ sudo grub-update
```

###Determine if the linux kernel has access to perf events
Run the following commands:

- sudo apt install -y linux-tools $(uname-r)
- perf list | grep power/
- modinfo rapl

