#!/bin/bash

# Enable exit on error / 启用错误退出 / エラーで終了を有効にする
set -e

# Function to handle errors / 处理错误的函数 / エラーを処理する関数
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
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $error_message" | tee -a ros2_install.log
    exit 1
}

# Trap errors and call error_exit function / 捕获错误并调用 error_exit 函数 / エラーをキャッチして error_exit 関数を呼び出す
trap 'error_exit $LINENO "$BASH_COMMAND"' ERR

# Detect system language / 检测系统语言 / システム言語を検出する
LANGUAGE=$(echo $LANG | cut -d'_' -f1)

# Log message function / 打印日志消息的函数 / ログメッセージ関数
log_message() {
    case $LANGUAGE in
        zh)
            echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a ros2_install.log
            ;;
        ja)
            echo "[$(date +'%Y-%m-%d %H:%M:%S')] $2" | tee -a ros2_install.log
            ;;
        *)
            echo "[$(date +'%Y-%m-%d %H:%M:%S')] $3" | tee -a ros2_install.log
            ;;
    esac
}

# Determine ROS 2 version based on Ubuntu version / 根据Ubuntu版本确定ROS 2版本 / Ubuntuバージョンに基づいてROS 2バージョンを決定する
UBUNTU_VERSION=$(lsb_release -sc)
case $UBUNTU_VERSION in
    "jammy")
        ROS2_VERSION=" "
        ;;
    "noble")
        ROS2_VERSION="jazzy"
        ;;
    *)
        error_exit $LINENO "不支持的Ubuntu版本: $UBUNTU_VERSION / サポートされていないUbuntuバージョン: $UBUNTU_VERSION / Unsupported Ubuntu version: $UBUNTU_VERSION"
        ;;
esac

# Check and install necessary tools / 检查并安装必要的工具 / 必要なツールをチェックしてインストールする
log_message "检查并安装必要的工具..." "必要なツールをチェックしてインストールしています..." "Checking and installing necessary tools..."
sudo apt update
sudo apt install -y curl gnupg lsb-release locales software-properties-common || error_exit $LINENO "安装必要的工具失败 / 必要なツールのインストールに失敗しました / Failed to install necessary tools"

# Set locale / 设置语言环境 / ロケールを設定する
log_message "设置语言环境..." "ロケールを設定しています..." "Setting locale..."
sudo locale-gen en_US en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8

# Ensure Universe repository is enabled / 确保启用 Universe 仓库 / Universe リポジトリが有効になっていることを確認する
log_message "启用 Universe 仓库..." "Universe リポジトリを有効にしています..." "Enabling Universe repository..."
sudo add-apt-repository universe

# Add the ROS 2 GPG key and repository / 添加ROS 2的GPG密钥和仓库 / ROS 2のGPGキーとリポジトリを追加する
log_message "添加ROS 2的GPG密钥和仓库..." "ROS 2のGPGキーとリポジトリを追加しています..." "Adding ROS 2 GPG key and repository..."
sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null

# Update package index / 更新软件包索引 / パッケージインデックスを更新する
log_message "更新软件包索引..." "パッケージインデックスを更新しています..." "Updating package index..."
sudo apt update || error_exit $LINENO "更新软件包索引失败 / パッケージインデックスの更新に失敗しました / Failed to update package index"

# Upgrade the system / 升级系统 / システムをアップグレードする
log_message "升级系统..." "システムをアップグレードしています..." "Upgrading the system..."
sudo apt upgrade -y || error_exit $LINENO "升级系统软件包失败 / システムパッケージのアップグレードに失敗しました / Failed to upgrade system packages"

# Install ROS 2 / 安装 ROS 2 / ROS 2 をインストールする
log_message "正在安装 ROS 2 ($ROS2_VERSION)..." "ROS 2 ($ROS2_VERSION) をインストールしています..." "Installing ROS 2 ($ROS2_VERSION)..."
sudo apt install ros-$ROS2_VERSION-desktop -y || error_exit $LINENO "安装 ROS 2 ($ROS2_VERSION) 失败 / ROS 2 ($ROS2_VERSION) のインストールに失敗しました / Failed to install ROS 2 ($ROS2_VERSION)"

# Environment setup / 设置环境 / 環境の設定
log_message "正在设置 ROS 2 环境..." "ROS 2 環境を設定しています..." "Setting up the ROS 2 environment..."
if ! sudo -u $USER grep -q "source /opt/ros/$ROS2_VERSION/setup.bash" ~/.bashrc; then
    echo "source /opt/ros/$ROS2_VERSION/setup.bash" >> ~/.bashrc || error_exit $LINENO "更新 .bashrc 失败 / .bashrc の更新に失敗しました / Failed to update .bashrc"
fi

# Source the updated bashrc / 重新加载 bashrc / bashrc を再読み込み
log_message "重新加载 .bashrc..." ".bashrc を再読み込みしています..." "Sourcing the updated bashrc..."
source ~/.bashrc || error_exit $LINENO "加载 .bashrc 失败 / .bashrc の読み込みに失敗しました / Failed to source .bashrc"

# Install development tools (optional) / 安装开发工具（可选） / 開発ツールをインストールする（オプション）
log_message "安装开发工具（可选）..." "開発ツールをインストールしています（オプション）..." "Installing development tools (optional)..."
sudo apt install python3-rosdep python3-rosinstall python3-colcon-common-extensions -y || error_exit $LINENO "安装依赖项失败 / 依存関係のインストールに失敗しました / Failed to install dependencies"

# Initialize rosdep / 初始化 rosdep / rosdep を初期化する
log_message "正在初始化 rosdep..." "rosdep を初期化しています..." "Initializing rosdep..."
if ! sudo rosdep init 2>/dev/null; then
    log_message "rosdep 已初始化 / rosdep はすでに初期化されています / rosdep already initialized"
fi
rosdep update || error_exit $LINENO "更新 rosdep 失败 / rosdep の更新に失敗しました / Failed to update rosdep"

# Clean up / 清理系统 / システムのクリーンアップ
log_message "正在清理系统..." "システムをクリーンアップしています..." "Cleaning up..."
sudo apt autoremove -y || error_exit $LINENO "自动移除软件包失败 / パッケージの自動削除に失敗しました / Failed to autoremove packages"
sudo apt clean || error_exit $LINENO "清理 apt 缓存失败 / apt キャッシュのクリーンに失敗しました / Failed to clean apt cache"

log_message "ROS 2 ($ROS2_VERSION) 安装成功完成！" "ROS 2 ($ROS2_VERSION) のインストールが正常に完了しました！" "ROS 2 ($ROS2_VERSION) installation completed successfully!"

