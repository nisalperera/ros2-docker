ARG ROS_DISTRO=humble
FROM osrf/ros:${ROS_DISTRO}-desktop-full

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
RUN apt update && \
    apt install -y sudo && \
    echo "$USER ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/$USER && \
    chmod 0440 /etc/sudoers.d/$USER

# Switch from root to user
USER $USER
ENV HOME=/home/$USER/

# Add user to video group to allow access to webcam
RUN sudo usermod --append --groups video $USER

# Switch to projects dir
WORKDIR /home/$USER/projects/

ENV LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH
ENV PATH=/usr/local/cuda/bin:/home/$USER/.local/bin/:$PATH

RUN sudo rm -rf /etc/localtime && sudo ln -s /usr/share/zoneinfo/Asia/Colombo /etc/localtime

RUN echo "\\nUpdate all packages \\n"
# Update all packages
RUN sudo apt clean && sudo apt update && sudo apt upgrade -y

RUN sudo apt update && sudo apt install -y --no-install-recommends \
    wget \
    gcc \
    g++ \
    curl \
    lsb-release \
    gnupg \
    freeglut3-dev \
    build-essential \
    dirmngr \
    ca-certificates \
    software-properties-common \
    apt-transport-https \
    dkms \
    curl -y && \
    sudo rm -rf /var/lib/apt/lists/*

ARG CUDA=false
ENV CUDA=${CUDA}
RUN if [ "$CUDA" = "true" ]; then \
        echo "\nInstall CUDA toolkit\n" && \
        # The following command removes an old key.
        # It may not be necessary for a fresh installation.
        sudo apt-key del 7fa2af80 && \
        # Fetches the new keyring for CUDA 12.1 on Ubuntu 22.04
        wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb && \
        sudo dpkg -i cuda-keyring_1.1-1_all.deb && \
        # Cleans up the downloaded keyring file
        rm cuda-keyring_1.1-1_all.deb && \
        sudo apt-get update && \
        # Installs CUDA 12.1, cuDNN 8.9.0, and TensorRT 8.6.1
        sudo apt-get install -y cuda-toolkit-12-1 \
                            libcudnn8=8.9.0.131-1+cuda12.1 \
                            libcudnn8-dev=8.9.0.131-1+cuda12.1 \
                            libnvinfer8=8.6.1.6-1+cuda12.1 \
                            libnvinfer-bin=8.6.1.6-1+cuda12.1 \
                            libnvinfer-dev=8.6.1.6-1+cuda12.1 \
                            libnvinfer-plugin8=8.6.1.6-1+cuda12.1 \
                            libnvinfer-plugin-dev=8.6.1.6-1+cuda12.1 \
                            libnvparsers8=8.6.1.6-1+cuda12.1 \
                            libnvparsers-dev=8.6.1.6-1+cuda12.1 \
                            libnvonnxparsers8=8.6.1.6-1+cuda12.1 \
                            libnvonnxparsers-dev=8.6.1.6-1+cuda12.1 \
                            libnvinfer-samples=8.6.1.6-1+cuda12.1 \
                            tensorrt=8.6.1.6-1+cuda12.1; \
    fi


# RUN sudo rm -rf cuda_12.2.2_535.104.05_linux.run
RUN echo "\\nAdding Deadsnakes PPA\\n"
RUN sudo add-apt-repository ppa:deadsnakes/ppa -y

RUN echo "\\nInstall Git, Python and PyQT5 \\n"
# Install Git, Python and PyQT5
RUN sudo apt install -y --no-install-recommends \
    git \
    python3-pip \
    python3-pyqt5 \
    python3-serial \
    libgl1 \
    libglx-mesa0 \
    joystick \
    evtest \
    jstest-gtk

RUN echo "export PATH=$PATH:$HOME/.local/lib/python3.10/site-packages"

RUN echo "\\nInstall ros2 packages including Gazebo \\n"
# Install ros2 packages including Gazebo 

RUN sudo curl https://packages.osrfoundation.org/gazebo.gpg --output /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] \
          http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" | \
          sudo tee /etc/apt/sources.list.d/gazebo-stable.list > /dev/null
          
RUN sudo apt update
RUN sudo apt install -y gz-harmonic

RUN sudo apt -y install \
    ros-${ROS_DISTRO}-ros-gz \
    ros-${ROS_DISTRO}-joint-state-publisher-gui \
    ros-${ROS_DISTRO}-controller-manager \
    ros-${ROS_DISTRO}-twist-mux \
    ros-${ROS_DISTRO}-twist-stamper \
    ros-${ROS_DISTRO}-slam-toolbox \
    ros-${ROS_DISTRO}-controller-manager \
    ros-${ROS_DISTRO}-joint-trajectory-controller \
    ros-${ROS_DISTRO}-joint-state-broadcaster \
    ros-${ROS_DISTRO}-ros2-control \
    ros-${ROS_DISTRO}-ros2-controllers \
    ros-${ROS_DISTRO}-ign-ros2-control \
    ros-${ROS_DISTRO}-navigation2 \
    ros-${ROS_DISTRO}-nav2-bringup \
    htop

ARG ULTRALYTICS=false
ENV DEEPLEARNING=${ULTRALYTICS}
RUN if [ "$ULTRALYTICS" = "true" ]; then \
        echo "\\nInstalling pytorch numpy and ultralytics and OpenCV... \\n" && \
        pip3 install numpy==1.24.* torch==2.4.1 torchvision==0.19.1 && \
        pip3 install ultralytics opencv-python lap; \
    fi

RUN . /opt/ros/${ROS_DISTRO}/setup.sh

RUN echo "\\nRosdep update \\n"
# Rosdep update
RUN rosdep update

# Install lowlatency kernel
RUN sudo apt update && sudo apt install linux-lowlatency -y

ARG PACKAGES="mobile_robot joy_tester"
ENV BUILD_PACKAGES=${PACKAGES}

RUN echo "\\nSource the ROS setup file and final configs \\n"
# Source the ROS setup file
RUN echo "source /opt/ros/$ROS_DISTRO/setup.bash" >> ~/.bashrc
RUN echo "export XDG_RUNTIME_DIR=/home/$USER" >> ~/.bashrc
RUN echo "export BUILD_PACKAGES=$BUILD_PACKAGES" >> ~/.bashrc
RUN echo "chmod 0700 /home/$USER" >> ~/.bashrc
RUN echo 'export PATH=/usr/local/cuda/bin${PATH:+:${PATH}}' >> ~/.bashrc
RUN echo 'export LD_LIBRARY_PATH=/usr/local/cuda-12.1/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}' >> ~/.bashrc


RUN sudo sh -c 'echo "@realtime soft rtprio 99" >> /etc/security/limits.conf'
RUN sudo sh -c 'echo "@realtime soft priority 99" >> /etc/security/limits.conf'
RUN sudo sh -c 'echo "@realtime soft memlock 102400" >> /etc/security/limits.conf'
RUN sudo sh -c 'echo "@realtime hard rtprio 99" >> /etc/security/limits.conf'
RUN sudo sh -c 'echo "@realtime hard priority 99" >> /etc/security/limits.conf'
RUN sudo sh -c 'echo "@realtime hard memlock 102400" >> /etc/security/limits.conf'

ENV GZ_VERSION=harmonic

RUN echo "export GZ_SIM_RESOURCE_PATH=$HOME/gazebo/:$HOME/gazebo/:$GZ_SIM_RESOURCE_PATH" >> $HOME/.bashrc
RUN echo "export IGN_GAZEBO_RESOURCE_PATH=$HOME/gazebo/:$IGN_GAZEBO_RESOURCE_PATH" >> $HOME/.bashrc

RUN sudo chmod +r /opt/ros/${ROS_DISTRO}/setup.bash

RUN sudo rm -rf /var/lib/apt/lists/*

CMD ["bash"]