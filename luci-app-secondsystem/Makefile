include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-secondsystem
PKG_VERSION:=1.1.0
PKG_RELEASE:=20260104

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-secondsystem
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
	$(INSTALL_DATA) ./luasrc/controller/secondsystem.lua $(1)/usr/lib/lua/luci/controller/secondsystem.lua

	# 2. 安装界面 (View)
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view/secondsystem
	$(INSTALL_DATA) ./luasrc/view/secondsystem/settings.htm $(1)/usr/lib/lua/luci/view/secondsystem/settings.htm

	# 3. 安装核心切换脚本 (至系统 PATH 路径)
	# 使用 INSTALL_BIN 会自动赋予 0755 权限，解决 sys.call 无法执行的问题
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./root/usr/bin/reboot_default_sys.sh $(1)/usr/bin/reboot_default_sys.sh
endef

$(eval $(call BuildPackage,luci-app-secondsystem))
