#!/usr/bin/env bash

echo "\\nFinalizing setup... \\n"

sudo addgroup realtime
sudo usermod -a -G realtime $(whoami)

sudo rm -rf /var/lib/apt/lists/*
sh $HOME/projects/remove.sh


colcon build --packages-select $BUILD_PACKAGES --symlink-install
echo "source $HOME/projects/install/setup.bash" >> ~/.bashrc