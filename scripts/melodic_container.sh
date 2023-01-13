#!/bin/bash
docker run -it -v /home/wsh/Documents/myRosProj/melodic_ws:/home/wsh/melodic_ws -v /home/wsh/Documents/myRosProj/bag_files/ros1_bags:/home/wsh/ros1_bags -v /tmp/.X11-unix:/tmp/.X11-unix:rw -v /dev/shm:/dev/shm -e DISPLAY=unix$DISPLAY -e NVIDIA_VISIBLE_DEVICES=all -e NVIDIA_DRIVER_CAPABILITIES=all --network host --privileged --rm --gpus all --name melodic wsh95/ros:melodic-desktop-full
