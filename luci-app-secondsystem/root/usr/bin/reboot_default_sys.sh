#!/bin/sh
# Program: 系统切换 (2026 稳定版)
# Description: 修复了 Web 调用时的路径与挂载检测问题
export PATH="/usr/sbin:/usr/bin:/sbin:/bin"

TARGET_DIR="/mnt/app_data"
DEVICE_NAME="ubi1_0"
PART_NAME="app_data"
UBI_CTRL="/dev/ubi_ctrl"
BOOT_2ND_FLAG_FILE="${TARGET_DIR}/boot_2nd_flag"

# 定义日志函数，方便在 Web 执行时查看
log_msg() {
    echo "$1"
    logger -t "SYS_SWITCH" "$1"
}

log_msg "--- 开始执行系统切换脚本 ---"

# --- 1. 动态获取 MTD 编号 ---
MTD_NUM=$(grep -w "$PART_NAME" /proc/mtd | cut -d: -f1 | sed 's/mtd//')

if [ -z "$MTD_NUM" ]; then
    log_msg "错误: 未能在 /proc/mtd 中找到名为 '$PART_NAME' 的分区。"
    exit 5
fi

# --- 2. 确保挂载点存在 ---
[ ! -d "$TARGET_DIR" ] && mkdir -p "$TARGET_DIR"

# --- 3. 挂载逻辑 (使用 /proc/mounts 替代 mountpoint) ---
if grep -qs "$TARGET_DIR" /proc/mounts; then
    log_msg "设备已挂载在 $TARGET_DIR"
else
    # 检查 UBI 设备节点是否已创建 (ubi1)
    if [ ! -e "/dev/ubi1" ]; then
        log_msg "正在关联 MTD $MTD_NUM 到 UBI..."
        ubiattach -m "$MTD_NUM" "$UBI_CTRL" 2>/dev/null
        # 等待内核生成设备节点
        sleep 1
    fi

    log_msg "正在挂载 $DEVICE_NAME 到 $TARGET_DIR ..."
    mount -t ubifs "$DEVICE_NAME" "$TARGET_DIR"
    
    if [ $? -ne 0 ]; then
        log_msg "挂载失败，请检查设备状态或驱动。"
        exit 2
    fi
fi

# --- 4. 标志文件处理 ---
if [ -f "$BOOT_2ND_FLAG_FILE" ]; then
    log_msg "找到切换标志，正在清理并重启..."
    rm -f "$BOOT_2ND_FLAG_FILE"
    sync
    # 给系统预留写盘时间
    sleep 2
    reboot
else
    log_msg "错误：未发现标志文件 $BOOT_2ND_FLAG_FILE，切换中断。"
    # 打印当前挂载目录内容以便调试
    log_msg "当前目录内容: $(ls $TARGET_DIR)"
    exit 4
fi