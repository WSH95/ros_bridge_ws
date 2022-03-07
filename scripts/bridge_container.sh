#!/bin/bash
docker run -it --network host -v /dev/shm:/dev/shm --rm wsh95/ros:ros1_bridge
