# ros2-docker

This project is for building a minimal ROS2 environment using vscode devcontainer, tailored for development, simulation, and robotics deployment tasks.

## Features

- Base ROS2 installation (specify distribution, e.g., Humble, Iron, etc.)
- Clean, slim image intended for development and CI/CD
- Easily extendable for custom robotics applications

## Getting Started

### Prerequisites

- Docker and VS Code installed on your system.
- VS Code plugins for docker and dev container installed.

### Build and Run the Dev Container

- Clone the repository and build the Docker image:

    ```bash
    git clone https://github.com/nisalperera/ros2-docker.git
    cd ros2-docker
    code .
    ```
- Press `CTRL+SHIFT+P`
- Select one of the following (You can type Dev Containers to filter these options):
    * Rebuild and Reopen in Container
    * Reopen in Container
    * Rebuild without cache and reopen in container

## Customization

- Modify the `Dockerfile` to install additional ROS2 packages or dependencies required for your project.
- You can also install additional packages when you are inside the container. (The above option is recommended)
- Extend with additional setup scripts or entrypoints as needed.

## TODO
- Add GPU support
- Cleanup Dockerfile and devcontainer.json

## License

This repository is licensed under the BSD-3-Clause License.
