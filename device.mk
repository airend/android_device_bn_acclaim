# Copyright (C) 2016 The CyanogenMod Project
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

TARGET_BOARD_OMAP_CPU := 4430

DEVICE_PACKAGE_OVERLAYS += $(DEVICE_FOLDER)/overlay/aosp

# rootfs
PRODUCT_COPY_FILES += \
	$(DEVICE_FOLDER)/recovery/init.recovery.acclaim.rc:root/init.recovery.acclaim.rc \
	$(DEVICE_FOLDER)/root/fstab.acclaim:root/fstab.acclaim \
	$(DEVICE_FOLDER)/root/init.acclaim.rc:root/init.acclaim.rc \
	$(DEVICE_FOLDER)/root/init.acclaim.usb.rc:root/init.acclaim.usb.rc \
	$(DEVICE_FOLDER)/root/ueventd.acclaim.rc:root/ueventd.acclaim.rc

# media
PRODUCT_COPY_FILES += \
	$(DEVICE_FOLDER)/prebuilt/etc/audio_policy.conf:/system/etc/audio_policy.conf \
	$(DEVICE_FOLDER)/prebuilt/etc/media_codecs.xml:/system/etc/media_codecs.xml \
	$(DEVICE_FOLDER)/prebuilt/etc/media_codecs_performance.xml:/system/etc/media_codecs_performance.xml \
	$(DEVICE_FOLDER)/prebuilt/etc/media_profiles.xml:system/etc/media_profiles.xml \
	frameworks/av/media/libstagefright/data/media_codecs_google_audio.xml:system/etc/media_codecs_google_audio.xml \
	frameworks/av/media/libstagefright/data/media_codecs_google_video.xml:system/etc/media_codecs_google_video.xml

# art
PRODUCT_COPY_FILES += \
	$(DEVICE_FOLDER)/prebuilt/poetry/poem.txt:root/sbin/poem.txt

# input
PRODUCT_COPY_FILES += \
	$(DEVICE_FOLDER)/prebuilt/usr/idc/ft5x06-i2c.idc:system/usr/idc/ft5x06-i2c.idc \
	$(DEVICE_FOLDER)/prebuilt/usr/keylayout/gpio-keys.kl:system/usr/keylayout/gpio-keys.kl

# wifi
PRODUCT_PACKAGES += \
	127x_TQS_S_2.6.ini \
	calibrator \
	crda \
	hostapd \
	hostapd.conf \
	lib_driver_cmd_wl12xx \
	regulatory.bin \
	wpa_supplicant \
	wpa_supplicant.conf

PRODUCT_COPY_FILES += \
	$(LOCAL_PATH)/prebuilt/etc/wifi/wpa_supplicant_overlay.conf:system/etc/wifi/wpa_supplicant_overlay.conf

# misc scripts
PRODUCT_COPY_FILES += \
	$(DEVICE_FOLDER)/prebuilt/bin/clearbootdata.sh:root/sbin/clearbootdata.sh \
	$(DEVICE_FOLDER)/prebuilt/bin/fix-mac.sh:/system/bin/fix-mac.sh \
	$(DEVICE_FOLDER)/prebuilt/bin/log_battery_data.sh:/system/bin/log_battery_data.sh

# hardware HALs
PRODUCT_PACKAGES += \
	audio.primary.acclaim \
	hwcomposer.acclaim \
	lights.acclaim \
	sensors.acclaim

# touchscreen firmware updater tool
PRODUCT_PACKAGES += \
	TFF

PRODUCT_CHARACTERISTICS := tablet
PRODUCT_AAPT_CONFIG := normal mdpi hdpi xhdpi
PRODUCT_AAPT_PREF_CONFIG := mdpi

PRODUCT_PROPERTY_OVERRIDES += \
	com.ti.omap_enhancement=true \
	config.disable_atlas=true \
	debug.hwui.render_dirty_regions=false \
	omap.audio.mic.main=AMic0 \
	omap.audio.mic.sub=AMic1 \
	omap.audio.power=PingPong \
	omap.enhancement=true \
	ro.bq.gpu_to_cpu_unsupported=1 \
	ro.carrier=wifi-only \
	ro.config.max_starting_bg=8 \
	ro.emulated_storage=true \
	ro.opengles.version=131072 \
	ro.sf.lcd_density=160 \
	ro.sys.fw.bg_apps_limit=16 \
	sys.io.scheduler=bfq \
	wifi.interface=wlan0

# permissions
PRODUCT_COPY_FILES += \
	$(DEVICE_FOLDER)/basic_hardware.xml:/system/etc/permissions/basic_hardware.xml \
	$(call add-to-product-copy-files-if-exists,packages/wallpapers/LivePicker/android.software.live_wallpaper.xml:system/etc/permissions/android.software.live_wallpaper.xml) \
	frameworks/native/data/etc/android.hardware.usb.accessory.xml:system/etc/permissions/android.hardware.usb.accessory.xml \
	frameworks/native/data/etc/android.hardware.wifi.xml:system/etc/permissions/android.hardware.wifi.xml \
	frameworks/native/data/etc/android.hardware.wifi.direct.xml:system/etc/permissions/android.hardware.wifi.direct.xml \
	frameworks/native/data/etc/android.software.sip.voip.xml:system/etc/permissions/android.software.sip.voip.xml

DEVICE_PACKAGE_OVERLAYS := $(DEVICE_FOLDER)/overlay/aosp

# filesystem management tools
PRODUCT_PACKAGES += \
	fsck.f2fs \
	mkfs.f2fs

# audio support
PRODUCT_PACKAGES += \
	Music \
	audio.a2dp.default \
	audio.r_submix.default \
	audio.usb.default \
	audio_policy.default \
	libaudioutils \
	tinycap \
	tinymix \
	tinyplay

# DRM
PRODUCT_PACKAGES += \
	libwvm

# misc / testing
PRODUCT_PACKAGES += \
	evtest \
	libjni_pinyinime \
	sh \
	strace

# platform
$(call inherit-product, hardware/ti/omap4/omap4.mk)
$(call inherit-product, hardware/ti/omap4/pvr-km.mk)

# blobs
$(call inherit-product-if-exists, vendor/ti/omap4/omap4-vendor.mk)
$(call inherit-product-if-exists, vendor/bn/acclaim/acclaim-vendor.mk)
$(call inherit-product-if-exists, vendor/widevine/arm-generic/widevine-vendor.mk)

# mem
PRODUCT_PROPERTY_OVERRIDES += \
    dalvik.vm.heapstartsize=8m \
    dalvik.vm.heapgrowthlimit=128m \
    dalvik.vm.heapsize=256m \
    dalvik.vm.heaptargetutilization=0.75 \
    dalvik.vm.heapminfree=512k \
    dalvik.vm.heapmaxfree=8m

# wifi
$(call inherit-product, hardware/ti/wlan/mac80211/wl127x-wlan-products.mk)
$(call inherit-product, hardware/ti/wlan/mac80211/wl12xx-wlan-modules.mk)
