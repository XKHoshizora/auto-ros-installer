#!/bin/bash

# 启用错误退出
set -e

# 处理错误的函数
error_exit() {
    local error_message
    case $LANGUAGE in
        zh)
            error_message="第 $1 行出错：$2"
            ;;
        ja)
            error_message="行 $1 でエラー: $2"
            ;;
        *)
            error_message="Error on line $1: $2"
            ;;
    esac
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $error_message" | tee -a ros_noetic_install.log
    exit 1
}

# 捕获错误并调用 error_exit 函数
trap 'error_exit $LINENO "$BASH_COMMAND"' ERR

# 检测系统语言
LANGUAGE=$(echo $LANG | cut -d'_' -f1)

# 打印日志消息的函数
log_message() {
    case $LANGUAGE in
        zh)
            echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a ros_noetic_install.log
            ;;
        ja)
            echo "[$(date +'%Y-%m-%d %H:%M:%S')] $2" | tee -a ros_noetic_install.log
            ;;
        *)
            echo "[$(date +'%Y-%m-%d %H:%M:%S')] $3" | tee -a ros_noetic_install.log
            ;;
    esac
}

# 配置Ubuntu仓库以允许 "restricted," "universe," 和 "multiverse"
log_message "配置Ubuntu仓库以允许 'restricted,' 'universe,' 和 'multiverse'..." "Ubuntuリポジトリを構成して 'restricted,' 'universe,' と 'multiverse' を許可しています..." "Configuring Ubuntu repositories to allow 'restricted,' 'universe,' and 'multiverse'..."
sudo add-apt-repository restricted
sudo add-apt-repository universe
sudo add-apt-repository multiverse

# 检查并安装必要的工具
log_message "检查并安装必要的工具..." "必要なツールをチェックしてインストールしています..." "Checking and installing necessary tools..."
sudo apt update
sudo apt install -y curl gnupg lsb-release || error_exit $LINENO "安装必要的工具失败 / 必要なツールのインストールに失敗しました / Failed to install necessary tools"

# 更新和升级系统
log_message "正在更新和升级系统..." "システムを更新してアップグレードしています..." "Updating and upgrading the system..."
sudo apt update || error_exit $LINENO "更新软件包索引失败 / パッケージインデックスの更新に失敗しました / Failed to update package index"
sudo apt upgrade -y || error_exit $LINENO "升级系统软件包失败 / システムパッケージのアップグレードに失敗しました / Failed to upgrade system packages"
sudo apt full-upgrade -y || error_exit $LINENO "执行完全升级失败 / フルアップグレードの実行に失敗しました / Failed to perform full upgrade"
sudo apt autoremove -y || error_exit $LINENO "自动移除软件包失败 / パッケージの自動削除に失敗しました / Failed to autoremove packages"

# 设置 sources.list
log_message "正在设置 sources.list..." "sources.list を設定しています..." "Setting up your sources.list..."
sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list' || error_exit $LINENO "设置 sources.list 失败 / sources.list の設定に失敗しました / Failed to set up sources.list"

# 设置密钥
log_message "正在设置密钥..." "キーを設定しています..." "Setting up your keys..."
curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add - || error_exit $LINENO "设置密钥失败 / キーの設定に失敗しました / Failed to set up keys"

# 更新软件包索引
log_message "更新软件包索引..." "パッケージインデックスを更新しています..." "Updating package index..."
sudo apt update || error_exit $LINENO "更新软件包索引失败 / パッケージインデックスの更新に失敗しました / Failed to update package index"

# 安装 ROS Noetic
log_message "正在安装 ROS Noetic..." "ROS Noetic をインストールしています..." "Installing ROS Noetic..."
sudo apt install ros-noetic-desktop-full -y || error_exit $LINENO "安装 ROS Noetic 失败 / ROS Noetic のインストールに失敗しました / Failed to install ROS Noetic"

# 设置环境
log_message "正在设置 ROS Noetic 环境..." "ROS Noetic 環境を設定しています..." "Setting up the ROS Noetic environment..."
if ! sudo -u $USER grep -q "source /opt/ros/noetic/setup.bash" ~/.bashrc; then
    echo "source /opt/ros/noetic/setup.bash" >> ~/.bashrc || error_exit $LINENO "更新 .bashrc 失败 / .bashrc の更新に失敗しました / Failed to update .bashrc"
fi

# Source the updated bashrc / 重新加载 bashrc / bashrc を再読み込み
log_message "重新加载 .bashrc..." ".bashrc を再読み込みしています..." "Sourcing the updated bashrc..."
source ~/.bashrc || error_exit $LINENO "加载 .bashrc 失败 / .bashrc の読み込みに失敗しました / Failed to source .bashrc"

# 安装构建软件包的依赖项
log_message "正在安装构建软件包的依赖项..." "パッケージを構築するための依存関係をインストールしています..." "Installing dependencies for building packages..."
sudo apt install python3-rosdep python3-rosinstall python3-rosinstall-generator python3-wstool build-essential -y || error_exit $LINENO "安装依赖项失败 / 依存関係のインストールに失敗しました / Failed to install dependencies"

# 初始化 rosdep
log_message "正在初始化 rosdep..." "rosdep を初期化しています..." "Initializing rosdep..."
sudo apt install python3-rosdep -y || error_exit $LINENO "安装 python3-rosdep 失败 / python3-rosdep のインストールに失敗しました / Failed to install python3-rosdep"
if ! sudo rosdep init 2>/dev/null; then
    log_message "rosdep 已初始化 / rosdep はすでに初期化されています / rosdep already initialized"
fi
rosdep update || error_exit $LINENO "更新 rosdep 失败 / rosdep の更新に失敗しました / Failed to update rosdep"

# 清理系统
log_message "正在清理系统..." "システムをクリーンアップしています..." "Cleaning up..."
sudo apt autoremove -y || error_exit $LINENO "自动移除软件包失败 / パッケージの自動削除に失敗しました / Failed to autoremove packages"
sudo apt clean || error_exit $LINENO "清理 apt 缓存失败 / apt キャッシュのクリーンに失敗しました / Failed to clean apt cache"

log_message "ROS Noetic 安装成功完成！" "ROS Noetic のインストールが正常に完了しました！" "ROS Noetic installation completed successfully!"

