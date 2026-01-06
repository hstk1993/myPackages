<<<<<<< HEAD
#!/bin/sh
# Program: 系统切换 (2026 稳定版)
# Fix: 使用 /proc/mounts 替代不存在的 mountpoint 命令
export PATH="/usr/sbin:/usr/bin:/sbin:/bin"
=======
#!/bin/bash
# Program: 动态获取分区并切换系统
# Update: 2026-01-04
>>>>>>> parent of da5a529 (dd)

TARGET_DIR="/mnt/app_data"
DEVICE_NAME="ubi1_0"
PART_NAME="app_data"  # <--- 请根据 cat /proc/mtd 里的名称修改此处
UBI_CTRL="/dev/ubi_ctrl"
BOOT_2ND_FLAG_FILE="${TARGET_DIR}/boot_2nd_flag"

# --- 1. 动态获取 MTD 编号 ---
# 通过匹配名称获取对应的 mtdX (例如 mtd7 -> 7)
MTD_NUM=$(grep -w "$PART_NAME" /proc/mtd | cut -d: -f1 | sed 's/mtd//')

if [ -z "$MTD_NUM" ]; then
    echo "错误: 未能在 /proc/mtd 中找到名为 '$PART_NAME' 的分区。"
    exit 5
fi

echo "确认分区 '$PART_NAME' 对应的编号为: MTD $MTD_NUM"

# --- 2. 确保挂载点存在 ---
[ ! -d "$TARGET_DIR" ] && mkdir -p "$TARGET_DIR"

# --- 3. 挂载逻辑 ---
if mountpoint -q "$TARGET_DIR"; then
    echo "设备已挂载."
else
    # 检查是否已经关联过 ubi (防止重复关联导致提示 Device or resource busy)
    if [ ! -e "/dev/ubi1" ]; then
        echo "正在关联 MTD $MTD_NUM 到 UBI..."
        ubiattach -m "$MTD_NUM" "$UBI_CTRL" 2>/dev/null
    fi

    echo "正在挂载 $DEVICE_NAME 到 $TARGET_DIR ..."
    mount -t ubifs "$DEVICE_NAME" "$TARGET_DIR"
    if [ $? -ne 0 ]; then
        echo "挂载失败，尝试检查驱动或设备状态。"
        exit 2
    fi
fi

# --- 4. 标志文件处理 ---
if [ -f "$BOOT_2ND_FLAG_FILE" ]; then
    echo "正在清理切换标志..."
    rm -f "$BOOT_2ND_FLAG_FILE" && sync
    echo "切换成功！系统正在重启..."
    sleep 2
    reboot
else
    echo "错误：未发现标志文件 $BOOT_2ND_FLAG_FILE，切换中断。"
    exit 4
fi
