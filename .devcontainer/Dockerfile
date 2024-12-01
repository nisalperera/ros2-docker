FROM nvidia/cuda:12.2.0-devel-ubuntu22.04

ARG ROS_DISTRO=humble
ENV ROS_DISTRO=$ROS_DISTRO

ARG DEBIAN_FRONTEND=noninteractive
RUN DEBIAN_FRONTEND="noninteractive" apt-get update && apt-get -y install tzdata

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

# Install prerequisites
RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends \
    wget \
    software-properties-common \
    curl \
    gnupg \
    lsb-release && \
    sudo rm -rf /var/lib/apt/lists/*

RUN echo "\\nAdding Deadsnakes PPA\\n"
RUN sudo add-apt-repository ppa:deadsnakes/ppa -y

RUN echo "\\nInstall Git, Python and PyQT5 \\n"
# Install Git, Python and PyQT5
RUN sudo apt install -y --no-install-recommends git python3-pip python3-pyqt5 libgl1-mesa-glx
# RUN echo "export PATH=$PATH:$HOME/.local/lib/python3.10/site-packages"

RUN echo "\\nInstall ROS `${ROS_DISTRO}` \\n"
# check for UTF-8
RUN locale
RUN sudo apt update && sudo apt install locales && \
    sudo locale-gen en_US en_US.UTF-8 && \
    sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 && \
    export LANG=en_US.UTF-8

RUN locale

# Enable Ubuntu Universe repository
RUN sudo apt install software-properties-common -y && \
    sudo add-apt-repository universe

RUN sudo apt update && sudo apt install curl -y

# Add the ROS 2 GPG key with apt.
RUN sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg

# Add the repository to the sources list
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null

RUN sudo apt update && sudo apt upgrade -y

# Install Desktop version which includes ROS, RViz, demos, tutorials.
RUN sudo apt install ros-${ROS_DISTRO}-desktop python3-argcomplete -y

# Install Compilers and other tools to build ROS packages
RUN sudo apt install ros-dev-tools -y

# RUN sudo chmod +x /home/$USER/projects/install_ros.sh
# RUN sh /home/$USER/projects/install_ros.sh

RUN echo "\\nInstall ros2 packages including Gazebo \\n"
# Install ros2 packages including Gazebo 
RUN sudo apt-get -y install \
    ros-${ROS_DISTRO}-ros-gz \
    ros-${ROS_DISTRO}-gazebo-ros-pkgs \
    ros-${ROS_DISTRO}-joint-state-publisher-gui \
    ros-${ROS_DISTRO}-xacro\
    htop

ARG ULTRALYTICS=false
RUN if [ "$ULTRALYTICS" = "true" ]; then \
        echo "\\nInstalling pytorch numpy and ultralytics and OpenCV... \\n" && \
        pip3 install numpy==1.24.* torch==2.4.1 torchvision==0.19.1 && \
        pip3 install ultralytics opencv-python lap; \
    fi

RUN sudo rm -rf /etc/localtime && sudo ln -s /usr/share/zoneinfo/Asia/Colombo /etc/localtime

RUN . /opt/ros/${ROS_DISTRO}/setup.sh

RUN sudo rm -rf /var/lib/apt/lists/*

# RUN echo "\\nRosdep update \\n"
# # Rosdep update
# RUN rosdep update


RUN echo "\\nSource the ROS setup file and final configs \\n"
# Source the ROS setup file
RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> ~/.bashrc
RUN echo "export XDG_RUNTIME_DIR=/home/$USER" >> ~/.bashrc
# RUN echo "export PYTHONPATH=$PYTHONPATH:$HOME/.local/lib/python3.10/site-packages"
RUN echo "chmod 0700 /home/$USER" >> ~/.bashrc

CMD ["bash"]