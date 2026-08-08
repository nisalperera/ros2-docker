ARG ROS_DISTRO=humble
ARG CUDA_VERSION=12.8.1-cudnn
ARG CUDA_DISTRO=ubuntu22.04

# Pull CUDA runtime + dev headers from the official NVIDIA image.
# This image is ONLY used as a file source — not as the final base.
FROM nvidia/cuda:${CUDA_VERSION}-devel-${CUDA_DISTRO} AS cuda-source

FROM osrf/ros:${ROS_DISTRO}-desktop-full

ENV USER=root
ARG LD_LIBRARY_PATH
ENV LD_LIBRARY_PATH=${LD_LIBRARY_PATH}

# ── Copy CUDA runtime, dev libraries, and headers from Stage 1 ──────────────
COPY --from=cuda-source /usr/local/cuda /usr/local/cuda
COPY --from=cuda-source /usr/lib/x86_64-linux-gnu/libcuda* /usr/lib/x86_64-linux-gnu/
COPY --from=cuda-source /usr/lib/x86_64-linux-gnu/libnvidia* /usr/lib/x86_64-linux-gnu/

# ── CUDA environment variables ───────────────────────────────────────────────
ENV CUDA_HOME=/usr/local/cuda
ENV PATH=/usr/local/cuda/bin:/${USER}/.local/bin/:${PATH}
ENV LD_LIBRARY_PATH=/usr/local/cuda/lib64:/usr/local/cuda/extras/CUPTI/lib64:${LD_LIBRARY_PATH}
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility

# Switch to home dir
WORKDIR /$USER/projects/

RUN echo "\\nUpdate all packages \\n"
# Update all packages
RUN apt-get clean && apt update && apt upgrade -y

RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    software-properties-common && \
    rm -rf /var/lib/apt/lists/*

RUN echo "\\nAdding Deadsnakes PPA\\n"
RUN add-apt-repository ppa:deadsnakes/ppa -y

RUN echo "\\nInstall Git, Python and PyQT5 \\n"
# Install Git, Python and PyQT5
RUN apt install -y --no-install-recommends \
    git \
    python3-pip \
    python3-pyqt5 \
    python3-serial \
    libgl1-mesa-glx \
    joystick \
    evtest \
    jstest-gtk

RUN echo "export PATH=$PATH:$HOME/.local/lib/python3.10/site-packages"

RUN echo "\\nInstall ros2 packages including Gazebo \\n"
# Install ros2 packages including Gazebo 
RUN apt-get -y install \
    ros-${ROS_DISTRO}-ros-gz \
    ros-${ROS_DISTRO}-ign-ros2-control \
    ros-${ROS_DISTRO}-ros-gz-sim \
    ros-${ROS_DISTRO}-ros-gz-bridge \
    ros-${ROS_DISTRO}-ros-gz-image \
    ros-${ROS_DISTRO}-joint-state-publisher-gui \
    ros-${ROS_DISTRO}-controller-manager \
    ros-${ROS_DISTRO}-twist-mux \
    ros-${ROS_DISTRO}-slam-toolbox \
    ros-${ROS_DISTRO}-controller-manager \
    ros-${ROS_DISTRO}-joint-trajectory-controller \
    ros-${ROS_DISTRO}-joint-state-broadcaster \
    ros-${ROS_DISTRO}-ros2-control \
    ros-${ROS_DISTRO}-ros2-controllers \
    ros-${ROS_DISTRO}-navigation2 \
    ros-${ROS_DISTRO}-nav2-bringup \
    ros-${ROS_DISTRO}-topic-tools \
    ros-${ROS_DISTRO}-robot-localization \
    htop

RUN rm -rf /etc/localtime && ln -s /usr/share/zoneinfo/Asia/Colombo /etc/localtime

RUN . /opt/ros/${ROS_DISTRO}/setup.sh

RUN rm -rf /var/lib/apt/lists/*

RUN echo "\\nRosdep update \\n"
# Rosdep update
# RUN rosdep update

# Install lowlatency kernel
RUN apt update && apt install linux-lowlatency -y

RUN echo "\\nSource the ROS setup file and final configs \\n"
# Source the ROS setup file
RUN echo "source /opt/ros/$ROS_DISTRO/setup.bash" >> ~/.bashrc
RUN echo "export XDG_RUNTIME_DIR=/$USER" >> ~/.bashrc
RUN echo "chmod 0700 /$USER" >> ~/.bashrc

RUN sh -c 'echo "@realtime soft rtprio 99" >> /etc/security/limits.conf'
RUN sh -c 'echo "@realtime soft priority 99" >> /etc/security/limits.conf'
RUN sh -c 'echo "@realtime soft memlock 102400" >> /etc/security/limits.conf'
RUN sh -c 'echo "@realtime hard rtprio 99" >> /etc/security/limits.conf'
RUN sh -c 'echo "@realtime hard priority 99" >> /etc/security/limits.conf'
RUN sh -c 'echo "@realtime hard memlock 102400" >> /etc/security/limits.conf'

# RUN pip3 install setuptools==58.2.0
RUN mkdir -p /$USER/.config/jstest-gtk

RUN mkdir -p ~/.gazebo/models \
    && cd ~/.gazebo/models \
    && wget -q -r -nH --no-parent --reject "index.html*" \
        http://models.gazebosim.org/construction_cone/ \
    && wget -q -r -nH --no-parent --reject "index.html*" \
        http://models.gazebosim.org/construction_barrel/

RUN echo "export IGN_GAZEBO_RESOURCE_PATH=$HOME/.gazebo/models:$IGN_GAZEBO_RESOURCE_PATH" >> ~/.bashrc
RUN echo 'export IGN_GAZEBO_SYSTEM_PLUGIN_PATH=/opt/ros/humble/lib:${IGN_GAZEBO_SYSTEM_PLUGIN_PATH}' >> ~/.bashrc

RUN echo "export __NV_PRIME_RENDER_OFFLOAD=1" >> ~/.bashrc
RUN echo "export __GLX_VENDOR_LIBRARY_NAME=nvidia" >> ~/.bashrc
RUN echo "export __VK_LAYER_NV_optimus=NVIDIA_only" >> ~/.bashrc

CMD ["bash"]