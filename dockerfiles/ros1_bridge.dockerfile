# build msgs package in ros1 environment
FROM ros:noetic-ros-base-focal as ros1_builder

RUN apt-get update && apt-get install -y git python3-catkin-tools \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /workspaces

# RUN /bin/bash -c 'source /opt/ros/noetic/setup.bash'

RUN git clone https://gitee.com/wsher/ros_bridge_ws.git

RUN /bin/bash -c 'cd ros_bridge_ws/ros1_ws/ && source /opt/ros/noetic/setup.bash && catkin_make install -DCMAKE_INSTALL_PREFIX=/opt/ros/noetic'


# Build msgs package in ros2 environment
FROM ros:foxy-ros-base-focal as ros2_builder

WORKDIR /workspaces

RUN git clone https://gitee.com/wsher/ros_bridge_ws.git

RUN /bin/bash -c 'cd ros_bridge_ws/ros2_ws/ && source /opt/ros/foxy/setup.bash && colcon build --merge-install --install-base /opt/ros/foxy'


# Create ros1(noetic) + ros2(foxy) environment for ros1_bridge
FROM ros:foxy-ros-base-focal as ros1_ros2_env

  #Install noetic
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu focal main" > /etc/apt/sources.list.d/ros1-latest.list' \
  && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654 \
  && apt-get update \
  && apt-get install -y ros-noetic-ros-base \
  && rm -rf /var/lib/apt/lists/*

  # Deps for the bridge
RUN apt-get update && apt-get install -y \
  libboost-filesystem-dev \
  libboost-math-dev \
  libboost-regex-dev \
  libboost-thread-dev \
  liblog4cxx-dev \
  && rm -rf /var/lib/apt/lists/*


# Build ros1_bridge in ros1+ros2 environment
FROM ros1_ros2_env as ros1_bridge_builder

  # Get the ros1 messages
COPY --from=ros1_builder /opt/ros/noetic /opt/ros/noetic

  # Get the ros2 messages
COPY --from=ros2_builder /opt/ros/foxy /opt/ros/foxy

  # Set up the environment
ENV LD_LIBRARY_PATH=/opt/ros/foxy/lib:/opt/ros/noetic/lib
ENV AMENT_PREFIX_PATH=/opt/ros/foxy
ENV ROS_ETC_DIR=/opt/ros/noetic/etc/ros
ENV COLCON_PREFIX_PATH=/opt/ros/foxy
ENV ROS_ROOT=/opt/ros/noetic/share/ros
ENV ROS_MASTER_URI=http://localhost:11311
ENV ROS_VERSION=2
ENV ROS_LOCALHOST_ONLY=0
ENV ROS_PYTHON_VERSION=3
ENV PYTHONPATH=/opt/ros/foxy/lib/python3.8/site-packages:/opt/ros/noetic/lib/python3/dist-packages
ENV ROS_PACKAGE_PATH=/opt/ros/noetic/share
ENV ROSLISP_PACKAGE_DIRECTORIES=
ENV PATH=/opt/ros/foxy/bin:/opt/ros/noetic/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV PKG_CONFIG_PATH=/opt/ros/noetic/lib/pkgconfig
ENV CMAKE_PREFIX_PATH=/opt/ros/foxy:/opt/ros/noetic

  # Build the bridge
WORKDIR /workspaces

RUN git clone https://gitee.com/wsher/ros_bridge_ws.git

RUN /bin/bash -c 'cd ros_bridge_ws/ros1_bridge_ws/ \
  && source /opt/ros/foxy/setup.bash \
  && colcon build --merge-install --packages-select ros1_bridge --cmake-force-configure --install-base /opt/ros/foxy'


# Run the ros1_bridge
FROM ros1_ros2_env

  # Copy the ros1 outputs
COPY --from=ros1_bridge_builder /opt/ros/noetic /opt/ros/noetic

  # Copy the ros2 outputs
COPY --from=ros1_bridge_builder /opt/ros/foxy /opt/ros/foxy

  # Set up the environment
ENV LD_LIBRARY_PATH=/opt/ros/foxy/lib:/opt/ros/noetic/lib
ENV AMENT_PREFIX_PATH=/opt/ros/foxy
ENV ROS_ETC_DIR=/opt/ros/noetic/etc/ros
ENV COLCON_PREFIX_PATH=/opt/ros/foxy
ENV ROS_ROOT=/opt/ros/noetic/share/ros
ENV ROS_MASTER_URI=http://localhost:11311
ENV ROS_VERSION=2
ENV ROS_LOCALHOST_ONLY=0
ENV ROS_PYTHON_VERSION=3
ENV PYTHONPATH=/opt/ros/foxy/lib/python3.8/site-packages:/opt/ros/noetic/lib/python3/dist-packages
ENV ROS_PACKAGE_PATH=/opt/ros/noetic/share
ENV ROSLISP_PACKAGE_DIRECTORIES=
ENV PATH=/opt/ros/foxy/bin:/opt/ros/noetic/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV PKG_CONFIG_PATH=/opt/ros/noetic/lib/pkgconfig
ENV CMAKE_PREFIX_PATH=/opt/ros/foxy:/opt/ros/noetic

RUN useradd --create-home --no-log-init --shell /bin/bash wsh \
  && adduser wsh sudo \
  && echo 'wsh:123' | chpasswd

USER wsh
WORKDIR /home/wsh

# RUN /bin/bash -c '. /opt/ros/foxy/setup.bash'

  # Run the print-pairs command to check if things are working properly
RUN ros2 run ros1_bridge dynamic_bridge --print-pairs

CMD ["bash", "-c", "source /opt/ros/foxy/setup.bash && ros2 run ros1_bridge dynamic_bridge --bridge-all-pairs"]
