# Copyright (C) 2013 The CyanogenMod Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

DEVICE_FOLDER := device/bn/acclaim

TARGET_KERNEL_HAVE_EXFAT := true

KERNEL_HAS_FINIT_MODULE := false

# inherit from the proprietary versions
-include vendor/ti/omap4/BoardConfigVendor.mk
-include vendor/bn/acclaim/BoardConfigVendor.mk
-include vendor/widevine/arm-generic/BoardConfigVendor.mk

# inherit from omap4
include hardware/ti/omap4/BoardConfigCommon.mk

TARGET_SPECIFIC_HEADER_PATH += $(DEVICE_FOLDER)/include

# no camera
USE_CAMERA_STUB := true

# no bluetooth
BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR := $(DEVICE_FOLDER)/bluetooth
BOARD_HAVE_BLUETOOTH := false

# connectivity - wi-fi
BOARD_WLAN_DEVICE := wl12xx_mac80211
BOARD_WPA_SUPPLICANT_DRIVER := NL80211
BOARD_WPA_SUPPLICANT_PRIVATE_LIB := lib_driver_cmd_wl12xx
USES_TI_MAC80211 := true
WPA_SUPPLICANT_VERSION := VER_0_8_X

# graphics
BOARD_EGL_WORKAROUND_BUG_10194508 := true
# set if the target supports FBIO_WAITFORVSYNC
TARGET_RUNNING_WITHOUT_SYNC_FRAMEWORK := true

# audio
BOARD_USES_GENERIC_AUDIO := false

# filesystem
BOARD_BOOTIMAGE_PARTITION_SIZE := 16777216
BOARD_FLASH_BLOCK_SIZE := 131072
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 15728640
BOARD_SYSTEMIMAGE_PARTITION_SIZE := 641728512
BOARD_USERDATAIMAGE_PARTITION_SIZE := 12949876736
BOARD_CACHEIMAGE_PARTITION_SIZE := 446693376
TARGET_USERIMAGES_USE_EXT4 := true
ifeq ($(HOST_OS),linux)
TARGET_USERIMAGES_USE_F2FS := true
endif

# vold
BOARD_VOLD_EMMC_SHARES_DEV_MAJOR := true
BOARD_VOLD_MAX_PARTITIONS := 32
TARGET_USE_CUSTOM_LUN_FILE_PATH := "/sys/devices/virtual/android_usb/android0/f_mass_storage/lun%d/file"

# Disable journaling on system.img to save space
BOARD_SYSTEMIMAGE_JOURNAL_SIZE := 0

# Only pre-optimize the boot image
WITH_DEXPREOPT_BOOT_IMG_ONLY := true

# Configure jemalloc for low-memory
MALLOC_SVELTE := true

# Use clang platform builds
USE_CLANG_PLATFORM_BUILD := true

# kernel/boot
BOARD_KERNEL_BASE := 0x80080000
BOARD_KERNEL_PAGESIZE := 4096
TARGET_BOOTLOADER_BOARD_NAME := acclaim
TARGET_NO_BOOTLOADER := true
TARGET_NO_RADIOIMAGE := true

TARGET_KERNEL_CONFIG := cyanogenmod_acclaim_defconfig
TARGET_KERNEL_SOURCE := kernel/bn/acclaim

ifneq (,$(strip $(wildcard $(TARGET_KERNEL_SOURCE)/drivers/gpu/ion/ion_page_pool.c)))
export BOARD_USE_TI_LIBION := false
endif

ifeq ($(ARM_EABI_TOOLCHAIN),)
TARGET_KERNEL_CROSS_COMPILE_PREFIX := arm-eabi-
KERNEL_TOOLCHAIN := $(ANDROID_TOOLCHAIN_2ND_ARCH)arm/$(TARGET_KERNEL_CROSS_COMPILE_PREFIX)$(TARGET_GCC_VERSION)/bin
ARM_EABI_TOOLCHAIN := $(KERNEL_TOOLCHAIN)
endif

ARM_CROSS_COMPILE ?= $(KERNEL_CROSS_COMPILE)

TARGET_RELEASETOOL_IMG_FROM_TARGET_SCRIPT := $(DEVICE_FOLDER)/releasetools/img_from_target_files
TARGET_RELEASETOOL_OTA_FROM_TARGET_SCRIPT := $(DEVICE_FOLDER)/releasetools/ota_from_target_files

# wlan build
WLAN_MODULES:
	make clean -C hardware/ti/wlan/mac80211/compat_wl12xx
	make -j8 -C hardware/ti/wlan/mac80211/compat_wl12xx KERNEL_DIR=$(KERNEL_OUT) KLIB=$(KERNEL_OUT) KLIB_BUILD=$(KERNEL_OUT) ARCH=arm CROSS_COMPILE=$(ARM_CROSS_COMPILE)
	mv hardware/ti/wlan/mac80211/compat_wl12xx/compat/compat.ko $(KERNEL_MODULES_OUT)
	mv hardware/ti/wlan/mac80211/compat_wl12xx/net/mac80211/mac80211.ko $(KERNEL_MODULES_OUT)
	mv hardware/ti/wlan/mac80211/compat_wl12xx/net/wireless/cfg80211.ko $(KERNEL_MODULES_OUT)
	mv hardware/ti/wlan/mac80211/compat_wl12xx/drivers/net/wireless/wl12xx/wl12xx.ko $(KERNEL_MODULES_OUT)
	mv hardware/ti/wlan/mac80211/compat_wl12xx/drivers/net/wireless/wl12xx/wl12xx_spi.ko $(KERNEL_MODULES_OUT)
	mv hardware/ti/wlan/mac80211/compat_wl12xx/drivers/net/wireless/wl12xx/wl12xx_sdio.ko $(KERNEL_MODULES_OUT)
	$(ARM_EABI_TOOLCHAIN)/arm-eabi-strip --strip-unneeded $(KERNEL_MODULES_OUT)/compat.ko $(KERNEL_MODULES_OUT)/mac80211.ko $(KERNEL_MODULES_OUT)/cfg80211.ko $(KERNEL_MODULES_OUT)/wl12xx.ko $(KERNEL_MODULES_OUT)/wl12xx_spi.ko $(KERNEL_MODULES_OUT)/wl12xx_sdio.ko

TARGET_KERNEL_MODULES := WLAN_MODULES

# external SGX module
SGX_MODULES:
	make clean -C $(HARDWARE_TI_OMAP4_BASE)/pvr-source/eurasiacon/build/linux2/omap4430_android
	cp $(TARGET_KERNEL_SOURCE)/drivers/video/omap2/omapfb/omapfb.h $(KERNEL_OUT)/drivers/video/omap2/omapfb/omapfb.h
	make -j8 -C $(HARDWARE_TI_OMAP4_BASE)/pvr-source/eurasiacon/build/linux2/omap4430_android ARCH=arm CROSS_COMPILE=$(ARM_CROSS_COMPILE) KERNELDIR=$(KERNEL_OUT) TARGET_PRODUCT="blaze_tablet" BUILD=release TARGET_SGX=540 PLATFORM_VERSION=4.0
	mv $(KERNEL_OUT)/../../target/kbuild/pvrsrvkm_sgx540_120.ko $(KERNEL_MODULES_OUT)
	$(ARM_EABI_TOOLCHAIN)/arm-eabi-strip --strip-unneeded $(KERNEL_MODULES_OUT)/pvrsrvkm_sgx540_120.ko

TARGET_KERNEL_MODULES += SGX_MODULES

EXFAT_MODULE:
	make clean -C external/exfat-nofuse KDIR=$(KERNEL_OUT)
	make -j8 -C external/exfat-nofuse ARCH=arm CROSS_COMPILE=$(ARM_CROSS_COMPILE) KDIR=$(KERNEL_OUT)
	mv external/exfat-nofuse/exfat.ko $(KERNEL_MODULES_OUT)
	$(ARM_EABI_TOOLCHAIN)/arm-eabi-strip --strip-unneeded $(KERNEL_MODULES_OUT)/exfat.ko

ifeq ($(TARGET_KERNEL_HAVE_EXFAT),true)
TARGET_KERNEL_MODULES += EXFAT_MODULE
endif

BOARD_SEPOLICY_DIRS += \
	$(DEVICE_FOLDER)/sepolicy

# boot.img
BOARD_CUSTOM_BOOTIMG_MK := $(DEVICE_FOLDER)/boot.mk
TARGET_NO_BOOTLOADER := true
TARGET_PROVIDES_RELEASETOOLS := true

# Don't give up on BusyBox
WITH_BUSYBOX_LINKS := true

# recovery.img
BOARD_CANT_BUILD_RECOVERY_FROM_BOOT_PATCH := true
BOARD_HAS_LARGE_FILESYSTEM := true
BOARD_HAS_NO_SELECT_BUTTON := true
BOARD_UMS_LUNFILE := "/sys/devices/virtual/android_usb/android0/f_mass_storage/lun/file"
TARGET_RECOVERY_FSTAB = $(DEVICE_FOLDER)/root/fstab.acclaim
TARGET_RECOVERY_PIXEL_FORMAT := "BGRA_8888"
TARGET_RECOVERY_PRE_COMMAND := "echo 'recovery' > /bootdata/BCB; sync"

# TWRP
DEVICE_RESOLUTION := 1024x600
RECOVERY_TOUCHSCREEN_FLIP_Y := true
RECOVERY_TOUCHSCREEN_SWAP_XY := true
TW_DEFAULT_EXTERNAL_STORAGE := true
TW_EXTERNAL_STORAGE_MOUNT_POINT := "sdcard"
TW_EXTERNAL_STORAGE_PATH := "/sdcard"
TW_INTERNAL_STORAGE_MOUNT_POINT := "emmc"
TW_INTERNAL_STORAGE_PATH := "/emmc"
TW_NO_REBOOT_BOOTLOADER := true
TW_NO_REBOOT_RECOVERY := true

