#!/bin/bash
docker run -e ROS_DOMAIN_ID=12 -it --network host -v /dev/shm:/dev/shm --rm --name bridge wsh95/ros:ros1_bridge
