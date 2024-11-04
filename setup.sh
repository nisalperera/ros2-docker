#!/bin/bash

. /opt/ros/humble/setup.sh

echo "\\nRosdep update \\n"
# Rosdep update
rosdep update

echo "\\nSource the ROS setup file and final configs \\n"
# Source the ROS setup file
echo "source /opt/ros/$ROS_DISTRO/setup.bash" >> ~/.bashrc
echo "export XDG_RUNTIME_DIR=/home/$USER" >> ~/.bashrc
echo "export PYTHONPATH=$PYTHONPATH:$HOME/.local/lib/python3.10/site-packages"
echo "chmod 0700 /home/$USER" >> ~/.bashrc

echo "\\nFinalizing setup... \\n"
sudo rm -rf /var/lib/apt/lists/*
sh $HOME/projects/remove.sh
