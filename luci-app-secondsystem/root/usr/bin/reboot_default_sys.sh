#!/bin/sh
# Program: 系统切换 (2026 稳定版)
# Fix: 使用 /proc/mounts 替代不存在的 mountpoint 命令
export PATH="/usr/sbin:/usr/bin:/sbin:/bin"

TARGET_DIR="/mnt/app_data"
DEVICE_NAME="ubi1_0"
PART_NAME="app_data"
BOOT_2ND_FLAG_FILE="${TARGET_DIR}/boot_2nd_flag"

echo "[$(date)] 开始系统切换流程..."

# 1. 动态获取 MTD 索引
MTD_NUM=$(grep -w "$PART_NAME" /proc/mtd | cut -d: -f1 | sed 's/mtd//')
if [ -z "$MTD_NUM" ]; then
    echo "错误: 未能在 /proc/mtd 中找到分区 $PART_NAME" >&2
    exit 1
fi

# 2. 替代 mountpoint: 检查 /proc/mounts 是否已存在目标挂载
if grep -q " $TARGET_DIR " /proc/mounts; then
    echo "设备已挂载在 $TARGET_DIR."
else
    echo "正在挂载 $DEVICE_NAME ..."
    [ ! -d "$TARGET_DIR" ] && mkdir -p "$TARGET_DIR"
    
    # 尝试关联 UBI 索引（忽略已关联的错误）
    ubiattach -m "$MTD_NUM" /dev/ubi_ctrl 2>/dev/null
    
    mount -t ubifs "$DEVICE_NAME" "$TARGET_DIR"
    if [ $? -ne 0 ]; then
        echo "挂载失败，请检查硬件状态。" >&2
        exit 2
    fi
fi

# 3. 切换逻辑 (MWAN/TTL 功能已在此版本移除)
if [ -f "$BOOT_2ND_FLAG_FILE" ]; then
    echo "发现切换标志，正在清理并同步数据..."
    rm -f "$BOOT_2ND_FLAG_FILE"
    
    if [ $? -eq 0 ]; then
        sync  # 关键：确保 Flash 写入完成
        echo "切换成功！系统即将在 2 秒后重启..."
        (sleep 2 && reboot) & 
        exit 0
    else
        echo "错误: 无法删除标志文件。" >&2
        exit 3
    fi
else
    echo "错误: 标志文件 $BOOT_2ND_FLAG_FILE 不存在，切换终止。" >&2
    exit 4
fi
