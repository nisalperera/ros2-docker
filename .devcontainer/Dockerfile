ARG ROS_DISTRO=foxy
# FROM nvidia/cuda:12.2.0-devel-ubuntu22.04 AS cuda_base
# ARG ROS_DISTRO=$ROS_DISTRO

FROM osrf/ros:${ROS_DISTRO}-desktop-full

# Set environment variables for NVIDIA
ENV NVIDIA_VISIBLE_DEVICES=${NVIDIA_VISIBLE_DEVICES:-all}
ENV NVIDIA_DRIVER_CAPABILITIES=${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics

# COPY --from=cuda-stage /usr/local /usr/local

# Add ubuntu user with same UID and GID as your host system, if it doesn't already exist
# Since Ubuntu 24.04, a non-root user is created by default with the name vscode and UID=1000
ARG USER=ubuntu
ENV USER=$USER
ARG UID=1000
ARG GID=$UID
RUN if ! id -u $UID >/dev/null 2>&1; then \
        groupadd --gid $GID $USER && \
        useradd -s /bin/bash --uid $UID --gid $GID -m $USER; \
    fi
# Add sudo support for the non-root user
RUN apt-get update && \
    apt-get install -y sudo && \
    echo "$USER ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/$USER && \
    chmod 0440 /etc/sudoers.d/$USER

# Switch from root to user
USER $USER

# Add user to video group to allow access to webcam
RUN sudo usermod --append --groups video $USER

# Switch to home dir
WORKDIR /home/$USER/projects/

ENV LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH
ENV PATH=/usr/local/cuda/bin:/home/$USER/.local/bin/:$PATH

RUN echo "\\nUpdate all packages \\n"
# Update all packages
RUN sudo apt-get clean && sudo apt update && sudo apt upgrade -y

RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends \
    wget \
    software-properties-common && \
    sudo rm -rf /var/lib/apt/lists/*

RUN echo "\\nAdding Deadsnakes PPA\\n"
RUN sudo add-apt-repository ppa:deadsnakes/ppa -y

RUN echo "\\nInstall Git, Python and PyQT5 \\n"
# Install Git, Python and PyQT5
RUN sudo apt install -y --no-install-recommends git python3-pip python3-pyqt5 libgl1-mesa-glx
RUN echo "export PATH=$PATH:$HOME/.local/lib/python3.10/site-packages"

RUN echo "\\nInstall ros2 packages including Gazebo \\n"
# Install ros2 packages including Gazebo 
RUN sudo apt-get -y install ros-${ROS_DISTRO}-ros-gz ros-${ROS_DISTRO}-gazebo-ros-pkgs ros-${ROS_DISTRO}-joint-state-publisher-gui htop

RUN echo "\\nInstalling pytorch numpy and ultralytics and OpenCV... \\n"
RUN pip3 install numpy==1.24.* torch==2.4.1 torchvision==0.19.1
RUN pip3 install ultralytics opencv-python lap 

RUN sudo rm -rf /etc/localtime && sudo ln -s /usr/share/zoneinfo/Asia/Colombo /etc/localtime

RUN . /opt/ros/humble/setup.sh

RUN sudo rm -rf /var/lib/apt/lists/*

RUN echo "\\nRosdep update \\n"
# Rosdep update
RUN rosdep update


RUN echo "\\nSource the ROS setup file and final configs \\n"
# Source the ROS setup file
RUN echo "source /opt/ros/$ROS_DISTRO/setup.bash" >> ~/.bashrc
RUN echo "export XDG_RUNTIME_DIR=/home/$USER" >> ~/.bashrc
RUN echo "export PYTHONPATH=$PYTHONPATH:$HOME/.local/lib/python3.10/site-packages"
RUN echo "chmod 0700 /home/$USER" >> ~/.bashrc

CMD ["bash"]