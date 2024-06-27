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
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $error_message" | tee -a ros_uninstall.log
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
            echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a ros_uninstall.log
            ;;
        ja)
            echo "[$(date +'%Y-%m-%d %H:%M:%S')] $2" | tee -a ros_uninstall.log
            ;;
        *)
            echo "[$(date +'%Y-%m-%d %H:%M:%S')] $3" | tee -a ros_uninstall.log
            ;;
    esac
}

# Check and get the ROS version to uninstall / 检查并获取要卸载的ROS版本 / アンインストールするROSのバージョンを確認して取得する
if [ -z "$1" ]; then
    error_exit $LINENO "未指定要卸载的ROS版本 / アンインストールするROSのバージョンが指定されていません / No ROS version specified for uninstallation"
fi

ROS_VERSION=$1

log_message "开始卸载ROS $ROS_VERSION..." "ROS $ROS_VERSIONのアンインストールを開始しています..." "Starting uninstallation of ROS $ROS_VERSION..."

# Uninstall ROS packages / 卸载ROS包 / ROSパッケージをアンインストールする
log_message "正在卸载ROS $ROS_VERSION的包..." "ROS $ROS_VERSIONのパッケージをアンインストールしています..." "Uninstalling ROS $ROS_VERSION packages..."
sudo apt-get purge "ros-$ROS_VERSION-*" -y || error_exit $LINENO "卸载ROS $ROS_VERSION的包失败 / ROS $ROS_VERSIONのパッケージのアンインストールに失敗しました / Failed to uninstall ROS $ROS_VERSION packages"

# Remove the ROS repository and keys / 移除ROS仓库和密钥 / ROSリポジトリとキーを削除する
log_message "正在移除ROS仓库和密钥..." "ROSリポジトリとキーを削除しています..." "Removing ROS repository and keys..."
sudo rm /etc/apt/sources.list.d/ros-latest.list || error_exit $LINENO "移除ROS仓库失败 / ROSリポジトリの削除に失敗しました / Failed to remove ROS repository"
sudo apt-key del F42ED6FBAB17C654 || error_exit $LINENO "移除ROS密钥失败 / ROSキーの削除に失敗しました / Failed to remove ROS key"

# Update package index / 更新软件包索引 / パッケージインデックスを更新する
log_message "更新软件包索引..." "パッケージインデックスを更新しています..." "Updating package index..."
sudo apt-get update || error_exit $LINENO "更新软件包索引失败 / パッケージインデックスの更新に失敗しました / Failed to update package index"

# Clean up / 清理系统 / システムのクリーンアップ
log_message "正在清理系统..." "システムをクリーンアップしています..." "Cleaning up..."
sudo apt-get autoremove -y || error_exit $LINENO "自动移除软件包失败 / パッケージの自動削除に失敗しました / Failed to autoremove packages"
sudo apt-get clean || error_exit $LINENO "清理apt缓存失败 / aptキャッシュのクリーンに失敗しました / Failed to clean apt cache"

# Remove sourced setup.bash from .bashrc / 从 .bashrc 中移除 sourced setup.bash / .bashrcからsourced setup.bashを削除する
log_message "从 .bashrc 中移除 sourced setup.bash..." ".bashrcからsourced setup.bashを削除しています..." "Removing sourced setup.bash from .bashrc..."
sed -i "/source \/opt\/ros\/$ROS_VERSION\/setup.bash/d" ~/.bashrc || error_exit $LINENO "移除 .bashrc 中的 setup.bash 失败 / .bashrc から setup.bash を削除するのに失敗しました / Failed to remove setup.bash from .bashrc"

log_message "ROS $ROS_VERSION 卸载成功完成！" "ROS $ROS_VERSION のアンインストールが正常に完了しました！" "ROS $ROS_VERSION uninstallation completed successfully!"