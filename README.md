# ROS 2 Foxy Docker

Dockerized ROS 2 Foxy environments for development, simulation, and experimentation using VSCode dev containers. This repository provides reproducible images and helper scripts so ROS 2 Foxy can run consistently across machines (laptops, workstations, or cloud instances).  

## Features

- Preconfigured ROS 2 Foxy Fitzroy on Ubuntu 20.04.  
- Separate images for lightweight CLI use and full desktop tooling (RViz, rqt, etc.).  
- Non‑interactive installation steps to make builds reliable in CI and headless environments.  
- Workspace layout ready for colcon builds and common ROS 2 development workflows.  

List of Dockerfiles:
- `Dockerfile.desktop` – desktop image with GUI tools.  
- `Dockerfile.dev` – development image with build tools, colcon, debugging utilities and additional ROS2 packages mentioned below.

Change the ```dockerfile``` section of [.devcontainer/devcontainer.json](./.devcontainer/devcontainer.json) to use your desired image

## Preinstalled ROS 2 Foxy packages (dev image only)

The development image comes with a curated ROS 2 Foxy stack for simulation, control, and navigation:

- `ros-foxy-gazebo-ros-pkgs` – Gazebo integration with ROS 2 plugins and utilities.  
- `ros-foxy-joint-state-publisher-gui` – GUI for publishing joint states in URDF/xacro workflows.  
- `ros-foxy-controller-manager` – Core controller manager for ros2_control.  
- `ros-foxy-twist-mux` – Multiplexer for combining multiple geometry_msgs/Twist command sources.  
- `ros-foxy-slam-toolbox` – 2D graph-based SLAM for online and offline mapping.  
- `ros-foxy-joint-trajectory-controller` – FollowJointTrajectory controller for arms and actuated joints.  
- `ros-foxy-joint-state-broadcaster` – Broadcaster for joint state interfaces in ros2_control.  
- `ros-foxy-ros2-control` – ros2_control framework for hardware abstraction and controllers.  
- `ros-foxy-ros2-controllers` – Standard controller implementations (e.g., joint state, trajectory controllers).  
- `ros-foxy-gazebo-ros2-control` – Gazebo plugin for integrating ros2_control with simulated hardware.  
- `ros-foxy-navigation2` – Nav2 navigation stack (planner, controller, recovery behaviors).  
- `ros-foxy-nav2-bringup` – Bringup launch files and configuration examples for Navigation2.  
- `ros-foxy-xacro` – Macro language support for generating URDF from xacro files.  

## Getting Started

1. Install Docker and VS Code (with the “Dev Containers” extension) on your host.  
2. Clone this repository and switch to the Foxy branch:
   ```bash
   git clone https://github.com/nisalperera/ros2-docker.git
   cd ros2-docker
   git checkout foxy
   ```
3. Open the folder in VS Code and reopen in container:
   - Open VS Code in `ros2-docker`.  
   - Press CTRL+SHIFT+P to open command palette, Search for “Dev Containers: Reopen in Container” and press enter to run it.
   - VS Code will build the ROS 2 Foxy dev image and start a container using the provided devcontainer configuration.

After the container starts, a ROS 2 Foxy environment with your workspace mounted is ready to use directly from the VS Code terminal.

## Development Workflow

Then inside the container:

```bash
source /opt/ros/foxy/setup.bash
cd /home/ubuntu/projects/{package name}
colcon build
source install/setup.bash
ros2 run <package> <node>
```

## License and third‑party components

This project is provided under the license specified in the repository. When using these Dockerfiles and images, ensure compliance with:

- ROS 2 licenses: Core ROS 2 code is generally licensed under Apache 2.0, with some components under BSD‑3‑Clause or other permissive licenses. Refer to the ROS 2 documentation and individual package LICENSE files for details.
- Docker licenses: Docker Engine is licensed under Apache 2.0, while Docker Desktop and related services are covered by Docker’s subscription and desktop license agreements. Check Docker’s official legal pages for up‑to‑date terms before commercial use.

Users are responsible for reviewing and complying with all applicable third‑party licenses when building and distributing images based on this repository.
