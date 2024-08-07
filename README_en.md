# Auto ROS Installer

[中文](README.md) | [English](README_en.md)

## Project Overview

This project contains shell scripts for automatically installing and uninstalling ROS1 and ROS2 on your system. These scripts simplify the installation and uninstallation process and help you quickly set up and remove the required ROS environment.

## Contents

- `install_ros1.sh`: Script for automatically installing ROS1 (ROS Noetic).
- `install_ros2.sh`: Script for automatically installing ROS2 (from ROS2 Humble and later LTS versions).
- `uninstall_ros.sh`: Script for automatically uninstalling a specified ROS version.

## Usage

### Prerequisites

Before running the scripts, make sure your system meets the following prerequisites:

- A supported version of Linux (e.g., Ubuntu 20.04 or later).
- `curl` and `wget` installed on your system.
- Proper permissions to execute shell scripts (you might need to use `sudo`).

### Installation

1. Clone the repository to your local machine:

   ```sh
   git clone https://github.com/XKHoshizora/auto-ros-installer.git
   cd auto-ros-installer
   ```

2. Run the script for the desired ROS version:

   - For ROS1 (ROS Noetic):

     ```sh
     chmod +x ./install_ros1.sh
     ./install_ros1.sh
     ```

   - For ROS2 (from ROS2 Humble and later LTS versions):

     ```sh
     chmod +x ./install_ros2.sh
     ./install_ros2.sh
     ```

3. Follow the on-screen instructions to complete the installation.

4. After the installation completes, please restart your terminal to ensure all changes take effect.

### Uninstallation

1. To uninstall a specified ROS version, run the `uninstall_ros.sh` script with the ROS version as an argument. For example:

   ```sh
   chmod +x uninstall_ros.sh
   sudo ./uninstall_ros.sh <ROS_version_name>
   ```

2. Follow the on-screen instructions to complete the uninstallation.

## Contributing

Contributions are welcome! If you have any improvements or bug fixes, please open an issue or submit a pull request.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.

## Contact Information

Project Maintainer: XKHoshizora - hoshizoranihon@gmail.com

Project Link: [https://github.com/XKHoshizora/auto-ros-installer](https://github.com/XKHoshizora/auto-ros-installer)

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=XKHoshizora/auto-ros-installer&type=Date)](https://star-history.com/#XKHoshizora/auto-ros-installer&Date)
