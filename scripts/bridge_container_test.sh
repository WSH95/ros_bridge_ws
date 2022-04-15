#!/bin/bash
docker run -it -e ROS_DOMAIN_ID=12 --network host -v /home/wsh/Documents/myRosProj/bag_files/ros1_bags:/home/wsh/Documents/ros1_bags -v /dev/shm:/dev/shm --rm --name ros1_bridge_test wsh95/ros:ros1_bridge_test
