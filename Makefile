#
# Copyright (C) 2021 ZeakyX
#

include $(TOPDIR)/rules.mk

PKG_NAME:=hklight
PKG_VERSION:=976678c7fbf9b453724c36f95781713a567761f3

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/brutella/hklight/tar.gz/$(PKG_VERSION)
PKG_HASH:=144434463d60d0b864da7b7bcac37a4512882918782f6337ffe12c61cf3cfd45

PKG_LICENSE_FILES:=LICENSE

PKG_CONFIG_DEPENDS:= \
	CONFIG_HKLIGHT_COMPRESS_GOPROXY \
	CONFIG_HKLIGHT_COMPRESS_UPX

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

GO_PKG:=github.com/brutella/hklight
GO_PKG_LDFLAGS:=-s -w
GO_PKG_LDFLAGS_X:=main.VersionString=v$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/hklight/config
config HKLIGHT_COMPRESS_GOPROXY
	bool "Compiling with GOPROXY proxy"
	default n

config HKLIGHT_COMPRESS_UPX
	bool "Compress executable files with UPX"
	default y
endef

ifeq ($(CONFIG_HKLIGHT_COMPRESS_GOPROXY),y)
	export GO111MODULE=on
	export GOPROXY=https://goproxy.baidu.com
endif

define Package/hklight
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Example project of a HomeKit light bulb using HomeControl
  URL:=https://github.com/brutella/hklight
  DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/hklight/description
	Example project of a HomeKit light bulb using HomeControl
endef

define Build/Compile
	$(call GoPackage/Build/Compile)
ifeq ($(CONFIG_HKLIGHT_COMPRESS_UPX),y)
	$(STAGING_DIR_HOST)/bin/upx --lzma --best $(GO_PKG_BUILD_BIN_DIR)/hklight
endif
endef

define Package/hklight/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(GO_PKG_BUILD_BIN_DIR)/hklight $(1)/usr/bin/$(PKG_NAME)
endef

$(eval $(call GoBinPackage,hklight))
$(eval $(call BuildPackage,hklight))
