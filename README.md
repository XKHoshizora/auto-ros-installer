# auto-ros-installer

This project contains shell scripts for automatically installing ROS1 and ROS2 on your system. These scripts simplify the installation process and help you quickly set up the required ROS environment.

## Contents

- `install_ros1.sh`: Script for automatically installing ROS1 (ROS Noetic).
- `install_ros2.sh`: Script for automatically installing ROS2 (from ROS2 Humble and later LTS versions).

## Usage

### Prerequisites

Before running the scripts, make sure your system meets the following prerequisites:

- A supported version of Linux (e.g., Ubuntu 18.04 or later).
- `curl` and `wget` installed on your system.
- Proper permissions to execute shell scripts (you might need to use `sudo`).

### Installation

1. Clone the repository to your local machine:

   ```sh
   git clone https://github.com/yourusername/auto-ros-installer.git
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

## Contributing

Contributions are welcome! If you have any improvements or bug fixes, please open an issue or submit a pull request.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.
