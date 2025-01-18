# ros2-docker
Dockerfile to create ROS2 container


# Setup on Window host with X-11 Forwarding

## X Server Setup
Install and configure VcXsrv (X server) on Windows:
- Download and install VcXsrv Windows X Server. (Open Powershell as Administrator)
    ```powershell
    choco install vcxsrv
    ```
- Launch XLaunch from the Start menu
- Select "Multiple windows" and set display number to 0
- **Uncheck** "Native opengl" and **check** "Disable access control"

## Note:
- Avoid using just `:0.0` as it relies on Unix domain sockets
- Use the full IP address format


