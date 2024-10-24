source /opt/ros/${ROS_DISTRO}/setup.bash

export GAZEBO_MODEL_PATH=$HOME/gazebo_models:/usr/share/gazebo-11/models/:$GAZEBO_MODEL_PATH
export GAZEBO_RESOURCE_PATH=$HOME/gazebo_worlds:$GAZEBO_RESOURCE_PATH
