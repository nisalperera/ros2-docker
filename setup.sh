#!/bin/bash

echo "Update all packages \\n"
# Update all packages
sudo apt-get clean && sudo apt update && sudo apt upgrade -y

sudo apt-get update && sudo apt-get install -y --no-install-recommends \
    wget \
    software-properties-common && \
    sudo rm -rf /var/lib/apt/lists/*


echo "Adding Deadsnakes PPA"
sudo add-apt-repository ppa:deadsnakes/ppa -y

echo "Install Git, Python and PyQT5 \\n"
# Install Git, Python and PyQT5
sudo apt install -y --no-install-recommends git python3-pip python3-pyqt5 libgl1-mesa-glx

echo "Install ros2 packages including Gazebo \\n"
# Install ros2 packages including Gazebo 
sudo apt-get -y install ros-${ROS_DISTRO}-ros-gz ros-${ROS_DISTRO}-gazebo-ros-pkgs ros-${ROS_DISTRO}-joint-state-publisher-gui htop

echo "Rosdep update \\n"
# Rosdep update
rosdep update

echo "Source the ROS setup file and final configs \\n"
# Source the ROS setup file
echo "source /opt/ros/$ROS_DISTRO/setup.bash" >> ~/.bashrc
echo "export XDG_RUNTIME_DIR=/home/$USER" >> ~/.bashrc
echo "export PYTHONPATH=$PYTHONPATH:$HOME/.local/lib/python3.10/site-packages"
echo "export PATH=$PATH:$HOME/.local/lib/python3.10/site-packages"
echo "chmod 0700 /home/$USER" >> ~/.bashrc

echo "Finalizing setup... \\n"
sudo rm -rf /var/lib/apt/lists/*
sh $HOME/projects/remove.sh