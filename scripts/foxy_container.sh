#!/bin/bash
docker run -it -v /tmp/.X11-unix:/tmp/.X11-unix:rw -v /dev/shm:/dev/shm -e DISPLAY=unix$DISPLAY -e NVIDIA_VISIBLE_DEVICES=all -e NVIDIA_DRIVER_CAPABILITIES=all --network host --privileged --rm --gpus all --name foxy wsh95/ros:foxy-desktop
