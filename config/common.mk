PRODUCT_BRAND ?= fh

PRODUCT_BUILD_PROP_OVERRIDES += BUILD_UTC_DATE=0

ifeq ($(PRODUCT_GMS_CLIENTID_BASE),)
PRODUCT_PROPERTY_OVERRIDES += \
    ro.com.google.clientidbase=android-google
else
PRODUCT_PROPERTY_OVERRIDES += \
    ro.com.google.clientidbase=$(PRODUCT_GMS_CLIENTID_BASE)
endif

PRODUCT_PROPERTY_OVERRIDES += \
    keyguard.no_require_sim=true

PRODUCT_PROPERTY_OVERRIDES += \
    ro.build.selinux=1

ifneq ($(TARGET_BUILD_VARIANT),user)
# Thank you, please drive thru!
PRODUCT_PROPERTY_OVERRIDES += persist.sys.dun.override=0
endif

ifneq ($(TARGET_BUILD_VARIANT),eng)
# Enable ADB authentication
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += ro.adb.secure=1
endif

ifeq ($(BOARD_CACHEIMAGE_FILE_SYSTEM_TYPE),)
  PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
    ro.device.cache_dir=/data/cache
else
  PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
    ro.device.cache_dir=/cache
endif

# Backup Tool
PRODUCT_COPY_FILES += \
    vendor/fh/prebuilt/common/bin/backuptool.sh:install/bin/backuptool.sh \
    vendor/fh/prebuilt/common/bin/backuptool.functions:install/bin/backuptool.functions \
    vendor/fh/prebuilt/common/bin/50-fh.sh:system/addon.d/50-fh.sh \
    vendor/fh/prebuilt/common/bin/blacklist:system/addon.d/blacklist

# Backup Services whitelist
PRODUCT_COPY_FILES += \
    vendor/fh/config/permissions/backup.xml:system/etc/sysconfig/backup.xml

# Lineage-specific broadcast actions whitelist
PRODUCT_COPY_FILES += \
    vendor/fh/config/permissions/lineage-sysconfig.xml:system/etc/sysconfig/lineage-sysconfig.xml

# Signature compatibility validation
PRODUCT_COPY_FILES += \
    vendor/fh/prebuilt/common/bin/otasigcheck.sh:install/bin/otasigcheck.sh

# init.d support
PRODUCT_COPY_FILES += \
    vendor/fh/prebuilt/common/bin/sysinit:system/bin/sysinit

ifneq ($(TARGET_BUILD_VARIANT),user)
# userinit support
PRODUCT_COPY_FILES += \
    vendor/fh/prebuilt/common/etc/init.d/90userinit:system/etc/init.d/90userinit
endif

# Copy all FireHound-specific init rc files
$(foreach f,$(wildcard vendor/lineage/prebuilt/common/etc/init/*.rc),\
       $(eval PRODUCT_COPY_FILES += $(f):system/etc/init/$(notdir $f)))


# Copy over added mimetype supported in libcore.net.MimeUtils
PRODUCT_COPY_FILES += \
    vendor/fh/prebuilt/common/lib/content-types.properties:system/lib/content-types.properties

# Enable SIP+VoIP on all targets
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.sip.voip.xml:system/etc/permissions/android.software.sip.voip.xml

# Enable wireless Xbox 360 controller support
PRODUCT_COPY_FILES += \
    frameworks/base/data/keyboards/Vendor_045e_Product_028e.kl:system/usr/keylayout/Vendor_045e_Product_0719.kl

# This is FireHound!
PRODUCT_COPY_FILES += \
    vendor/fh/config/permissions/org.lineageos.android.xml:system/etc/permissions/org.lineageos.android.xml \
    vendor/fh/config/permissions/privapp-permissions-lineage.xml:system/etc/permissions/privapp-permissions-lineage.xml

# Include FireHound audio files
include vendor/fh/config/fh_audio.mk

ifneq ($(TARGET_DISABLE_LINEAGE_SDK), true)
# Lineage SDK
include vendor/fh/config/lineage_sdk_common.mk
endif

# TWRP
ifeq ($(WITH_TWRP),true)
include vendor/fh/config/twrp.mk
endif

# Bootanimation
PRODUCT_COPY_FILES += \
    vendor/fh/prebuilt/common/media/bootanimation.zip:system/media/bootanimation.zip

# Required Lineage packages
PRODUCT_PACKAGES += \
    BluetoothExt \
    LineageParts \
    Development \
    Profiles

# Optional packages
PRODUCT_PACKAGES += \
    libemoji \
    LiveWallpapersPicker \
    PhotoTable \
    Terminal

# Include explicitly to work around GMS issues
PRODUCT_PACKAGES += \
    libprotobuf-cpp-full \
    librsjni

# Custom Lineage packages
PRODUCT_PACKAGES += \
    AudioFX \
    LineageSettingsProvider \
    Eleven \
    ExactCalculator \
    LockClock \
    WallpaperPicker \
    WeatherProvider

# Themes
PRODUCT_PACKAGES += \
    PixelTheme \
    Stock

# Launcher3
PRODUCT_PACKAGES += \
    Launcher3

# Exchange support
PRODUCT_PACKAGES += \
    Exchange2

# Extra tools in FireHound
PRODUCT_PACKAGES += \
    7z \
    bash \
    bzip2 \
    curl \
    fsck.ntfs \
    gdbserver \
    htop \
    lib7z \
    libsepol \
    micro_bench \
    mke2fs \
    mkfs.ntfs \
    mount.ntfs \
    oprofiled \
    pigz \
    powertop \
    sqlite3 \
    strace \
    tune2fs \
    unrar \
    unzip \
    vim \
    wget \
    zip

# Charger
PRODUCT_PACKAGES += \
    charger_res_images

# Custom off-mode charger
ifeq ($(WITH_LINEAGE_CHARGER),true)
PRODUCT_PACKAGES += \
    lineage_charger_res_images \
    font_log.png \
    libhealthd.lineage
endif

# ExFAT support
WITH_EXFAT ?= true
ifeq ($(WITH_EXFAT),true)
TARGET_USES_EXFAT := true
PRODUCT_PACKAGES += \
    mount.exfat \
    fsck.exfat \
    mkfs.exfat
endif

# Openssh
PRODUCT_PACKAGES += \
    scp \
    sftp \
    ssh \
    sshd \
    sshd_config \
    ssh-keygen \
    start-ssh

# rsync
PRODUCT_PACKAGES += \
    rsync

# Stagefright FFMPEG plugin
PRODUCT_PACKAGES += \
    libffmpeg_extractor \
    libffmpeg_omx \
    media_codecs_ffmpeg.xml

PRODUCT_PROPERTY_OVERRIDES += \
    media.sf.omx-plugin=libffmpeg_omx.so \
    media.sf.extractor-plugin=libffmpeg_extractor.so

# Storage manager
PRODUCT_PROPERTY_OVERRIDES += \
    ro.storage_manager.enabled=true

# Media
PRODUCT_PROPERTY_OVERRIDES += \
    media.recorder.show_manufacturer_and_model=true

# These packages are excluded from user builds
ifneq ($(TARGET_BUILD_VARIANT),user)
PRODUCT_PACKAGES += \
    procmem \
    procrank

# Conditionally build in su
ifeq ($(WITH_SU),true)
PRODUCT_PACKAGES += \
    su
endif
endif

DEVICE_PACKAGE_OVERLAYS += vendor/fh/overlay/common

PRODUCT_EXTRA_RECOVERY_KEYS += \
    vendor/fh/build/target/product/security/fh

-include vendor/fh-priv/keys/keys.mk

-include $(WORKSPACE)/build_env/image-auto-bits.mk
-include vendor/fh/config/partner_gms.mk
-include vendor/cyngn/product.mk

$(call prepend-product-if-exists, vendor/extra/product.mk)
$(call inherit-product, vendor/fh/config/firehound.mk)
