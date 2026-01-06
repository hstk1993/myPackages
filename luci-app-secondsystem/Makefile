# Copyright (C) 2023 Siriling <siriling@qq.com>
# This is free software, licensed under the GNU General Public License v3.

include $(TOPDIR)/rules.mk


PKG_NAME:=luci-app-secondsystem
LUCI_TITLE:=Luci Secondsystem Support for Nradio660
LUCI_PKGARCH:=all
PKG_VERSION:=1.0.0
LUCI_DEPENDS:=+luci
		

include $(TOPDIR)/feeds/luci/luci.mk

<<<<<<< HEAD
define Package/$(PKG_NAME)
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=LuCI App Secondsystem for Nradio 660 (2026 Optimized)
  # 增加 ubi-utils 依赖，确保 sys.call 调用 ubiattach 时命令存在
  DEPENDS:=+luci +ubi-utils
endef

define Build/Compile
endef

define Package/luci-app-secondsystem/install
	# 1. 安装控制器 (Controller)
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DATA) ./luasrc/controller/second_system.lua $(1)/usr/lib/lua/luci/controller/second_system.lua

	# 2. 安装界面 (View)
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view
	$(INSTALL_DATA) ./luasrc/view/settings.htm $(1)/usr/lib/lua/luci/view/settings.htm

	# 3. 安装核心切换脚本 (至系统 PATH 路径)
	# 使用 INSTALL_BIN 会自动赋予 0755 权限，解决 sys.call 无法执行的问题
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./root/usr/bin/reboot_default_sys.sh $(1)/usr/bin/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
=======
# call BuildPackage - OpenWrt buildroot signature
>>>>>>> parent of da5a529 (dd)
