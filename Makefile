
KMODULE_NAME = ssv6x5x

ARCH ?= arm
KSRC ?= $(HOME)/firmware/output/build/linux-custom
CROSS_COMPILE ?= $(HOME)/firmware/output/per-package/linux/host/opt/ext-toolchain/bin/arm-linux-

KBUILD_TOP ?= $(PWD)
SSV_DRV_PATH ?= $(PWD)

include $(KBUILD_TOP)/config.mak

EXTRA_CFLAGS := -I$(KBUILD_TOP) -I$(KBUILD_TOP)/include

# Generate version strings
# GEN_VER := $(shell cd $(KBUILD_TOP); ./ver_info.pl include/ssv_version.h)
# Generate include/ssv_conf_parser.h
# GEN_CONF_PARSER := $(shell cd $(KBUILD_TOP); env ccflags="$(ccflags-y)" ./parser-conf.sh include/ssv_conf_parser.h)
# Generate $(KMODULE_NAME)-wifi.cfg
#BKP_CFG := $(shell cp $(KBUILD_TOP)/$(KMODULE_NAME)-wifi.cfg $(KBUILD_TOP)/image/$(KMODULE_NAME)-wifi.cfg)

#EXTRA_CFLAGS := -I$(KBUILD_TOP) -I$(KBUILD_TOP)/include

#DEF_PARSER_H = $(KBUILD_TOP)/include/ssv_conf_parser.h
#$(shell env ccflags="$(ccflags-y)" $(KBUILD_TOP)/parser-conf.sh $(DEF_PARSER_H))

KERN_SRCS := ssvdevice/ssvdevice.c
KERN_SRCS += ssvdevice/ssv_cmd.c

KERN_SRCS += hci/ssv_hci.c

KERN_SRCS += smac/regd.c
KERN_SRCS += smac/wow.c
KERN_SRCS += smac/hw_scan.c
KERN_SRCS += smac/init.c
KERN_SRCS += smac/ssv_skb.c
KERN_SRCS += smac/dev.c
KERN_SRCS += smac/ap.c
KERN_SRCS += smac/efuse.c
KERN_SRCS += smac/ssv_pm.c
KERN_SRCS += smac/ssv_skb.c

ifeq ($(findstring -DCONFIG_SSV6XXX_DEBUGFS, $(ccflags-y)), -DCONFIG_SSV6XXX_DEBUGFS)
KERN_SRCS += smac/ssv6xxx_debugfs.c
endif

ifeq ($(findstring -DCONFIG_SSV_CTL, $(ccflags-y)), -DCONFIG_SSV_CTL)
KERN_SRCS += smac/ssv_wifi_ctl.c
endif
ifeq ($(findstring -DCONFIG_SSV_SMARTLINK, $(ccflags-y)), -DCONFIG_SSV_SMARTLINK)
KERN_SRCS += smac/kssvsmart.c
endif

KERN_SRCS += smac/hal/hal.c
ifeq ($(findstring -DSSV_SUPPORT_SSV6006, $(ccflags-y)), -DSSV_SUPPORT_SSV6006)
KERN_SRCS += hwif/usb/usb.c
KERN_SRCS += smac/hal/ssv6006c/ssv6006_common.c
KERN_SRCS += smac/hal/ssv6006c/ssv6006C_mac.c
KERN_SRCS += smac/hal/ssv6006c/ssv6006_phy.c
KERN_SRCS += smac/hal/ssv6006c/ssv6006_turismoC.c
ifeq ($(findstring -DSSV_SUPPORT_SSV6006AB, $(ccflags-y)), -DSSV_SUPPORT_SSV6006AB)
KERN_SRCS += smac/hal/ssv6006/ssv6006_mac.c
KERN_SRCS += smac/hal/ssv6006/ssv6006_cabrioA.c
KERN_SRCS += smac/hal/ssv6006/ssv6006_geminiA.c
KERN_SRCS += smac/hal/ssv6006/ssv6006_turismoA.c
KERN_SRCS += smac/hal/ssv6006/ssv6006_turismoB.c
endif
endif

KERN_SRCS += hwif/sdio/sdio.c
KERN_SRCS += hwif/hal/hwif_hal.c
ifeq ($(findstring -DSSV_SUPPORT_SSV6006, $(ccflags-y)), -DSSV_SUPPORT_SSV6006)
KERN_SRCS += hwif/hal/ssv6006c/ssv6006C_hwif.c
endif

KERN_SRCS += $(KMODULE_NAME)-generic-wlan.c

$(KMODULE_NAME)-y += $(KERN_SRCS_S:.S=.o)
$(KMODULE_NAME)-y += $(KERN_SRCS:.c=.o)

obj-$(CONFIG_SSV6X5X) += $(KMODULE_NAME).o

all: modules

modules:
	$(MAKE) -C $(KSRC) M=$(SSV_DRV_PATH) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) modules

strip:
	$(CROSS_COMPILE)strip $(KMODULE_NAME).ko --strip-unneeded

clean:
	$(MAKE) -C $(KSRC) M=$(SSV_DRV_PATH) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) clean
