




rm -rf .repo/local_manifests/
rm -rf device/lge
rm -rf vendor/lge/msm8996-common kernel/lge/msm8996
rm -rf vendor/evolution-priv/keys
#rm -rf out/target/product/*/obj/KERNEL_OBJ

#repo init -u https://github.com/crdroidandroid/android.git -b 16.0 --depth=1 --git-lfs
#repo init -u https://github.com/Evolution-X/manifest -b bka --git-lfs --depth=1
repo init -u https://github.com/crdroidandroid/android.git -b 15.0 --git-lfs --depth=1
git clone https://github.com/xc112lg/local_manifests --depth 1 -b lgcrd .repo/local_manifests
repo sync -c -j64 --force-sync --no-clone-bundle --no-tags
/opt/crave/resync.sh
# export TARGET_USES_PICO_GAPPS=true
# export TARGET_ENABLE_BLUR=false
# export WITH_ADB_INSECURE=true
# export SELINUX_IGNORE_NEVERALLOWS=true
export WITH_GMS=false
export TARGET_USES_PICO_GAPPS=true
sed -i '$a -include vendor/lineage-priv/keys/keys.mk' device/lge/msm8996-common/msm8996.mk

mkdir -p device/lge/msm8996-common/sepolicy/vendor-user
if [ ! -f device/lge/msm8996-common/sepolicy/vendor-user/file.te ]; then
    echo 'type sensors_data_file, file_type, data_file_type;' > device/lge/msm8996-common/sepolicy/vendor-user/file.te
fi
grep -q "sepolicy/vendor-user" device/lge/msm8996-common/BoardConfigCommon.mk || cat >> device/lge/msm8996-common/BoardConfigCommon.mk << 'EOF'

ifeq ($(TARGET_BUILD_VARIANT),user)
BOARD_VENDOR_SEPOLICY_DIRS += $(COMMON_PATH)/sepolicy/vendor-user
endif
EOF


source <(curl -sf https://raw.githubusercontent.com/xc112lg/evolutiion_lgg6/refs/heads/main/rbe8.sh)  >/dev/null 2>&1

 mkdir -p device/lge/msm8996-common/overlay/frameworks/base/core/res/res/values
    curl -sf -o device/lge/msm8996-common/overlay/frameworks/base/core/res/res/values/cr_config.xml \
        https://raw.githubusercontent.com/crdroidandroid/android_frameworks_base/15.0/core/res/res/values/cr_config.xml

    mkdir -p device/lge/msm8996-common/overlay/frameworks/base/packages/SystemUI/res/values
    curl -sf -o device/lge/msm8996-common/overlay/frameworks/base/packages/SystemUI/res/values/cr_config.xml \
        https://raw.githubusercontent.com/crdroidandroid/android_frameworks_base/15.0/packages/SystemUI/res/values/cr_config.xml
#    sed -i 's|"maintainer": "\${MAINTAINER:-}"|"maintainer": "xc112lg"|' vendor/lineage/build/tools/createjson.sh
#    sed -i 's|https://raw\.githubusercontent\.com/crdroidandroid|https://raw.githubusercontent.com/xc112lg|g' packages/apps/Settings/src/com/android/settings/deviceinfo/firmwareversion/BuildMaintainerPreference.kt

mkdir -p device/lge/msm8996-common/sepolicy/private

# priv_app.te
[ -f device/lge/msm8996-common/sepolicy/private/priv_app.te ] || : > device/lge/msm8996-common/sepolicy/private/priv_app.te
printf '%s\n' \
  'allow priv_app mnt_pass_through_file:dir getattr;' \
  'allow priv_app mnt_pass_through_file:dir search;' \
  'allow priv_app qemu_hw_prop:file read;' \
  'allow priv_app keyguard_config_prop:file read;' \
  'allow priv_app storage_config_prop:file read;' \
  'allow priv_app vendor_file:file read;' \
  'allow priv_app vr_manager_service:service_manager find;' \
  'allow priv_app ota_package_file:dir { read getattr };' \
  >> device/lge/msm8996-common/sepolicy/private/priv_app.te

# untrusted_app.te
[ -f device/lge/msm8996-common/sepolicy/private/untrusted_app.te ] || : > device/lge/msm8996-common/sepolicy/private/untrusted_app.te
printf '%s\n' \
  'allow untrusted_app_32 vendor_file:file read;' \
  'allow untrusted_app vendor_file:file read;' \
  >> device/lge/msm8996-common/sepolicy/private/untrusted_app.te

# vold_prepare_subdirs.te
[ -f device/lge/msm8996-common/sepolicy/private/vold_prepare_subdirs.te ] || : > device/lge/msm8996-common/sepolicy/private/vold_prepare_subdirs.te
printf '%s\n' \
  'allow vold_prepare_subdirs vendor_file:file read;' \
  >> device/lge/msm8996-common/sepolicy/private/vold_prepare_subdirs.te

# recheck
echo "== priv_app.te =="; cat device/lge/msm8996-common/sepolicy/private/priv_app.te
echo "== untrusted_app.te =="; cat device/lge/msm8996-common/sepolicy/private/untrusted_app.te
echo "== vold_prepare_subdirs.te =="; cat device/lge/msm8996-common/sepolicy/private/vold_prepare_subdirs.te



source build/envsetup.sh




# lunch lineage_h872-bp1a-userdebug
# #lunch lineage_h872-bp4a-userdebug
# make installclean
# m evolution

# lunch lineage_h870-bp1a-userdebug

# make installclean
# m evolution

# lunch lineage_us997-bp1a-userdebug

# make installclean
# m evolution

# rm -rf packages/apps/ViPER4AndroidFX
# git clone https://github.com/TogoFire/packages_apps_ViPER4AndroidFX.git packages/apps/ViPER4AndroidFX

# # 1. msm8996.mk — inherit the V4A product config
# sed -i '/\$(call inherit-product, vendor\/lge\/msm8996-common\/msm8996-common-vendor.mk)/a\
# \
# # ViPER4Android\
# $(call inherit-product, packages/apps/ViPER4AndroidFX/config.mk)' device/lge/msm8996-common/msm8996.mk

# # 2. audio/audio_effects.xml — register the v4a_re library
# sed -i '/<library name="volume_listener" path="libvolumelistener.so"\/>/a\
#         <library name="v4a_re" path="libv4a_re.so"/>' device/lge/msm8996-common/audio/audio_effects.xml

# # 3. audio/audio_effects.xml — register the v4a_standard_re effect
# sed -i '/<effect name="notification_helper" library="volume_listener" uuid="0b776dde-0590-11e5-81ba-0025b32654a0"\/>/a\
#         <effect name="v4a_standard_re" library="v4a_re" uuid="90380da3-8536-4744-a6a3-5731970e640f"/>' device/lge/msm8996-common/audio/audio_effects.xml

# # 4. sepolicy/vendor/audioserver.te — file access + prop read
# sed -i '/allow audioserver mpctl_socket:sock_file write;/a\
# \
# # ViPER4Android\
# get_prop(audioserver, vendor_audio_prop)\
# allow audioserver unlabeled:file { read write open getattr };' device/lge/msm8996-common/sepolicy/vendor/audioserver.te

# # 5. sepolicy/vendor/hal_audio_default.te — execmem for the native effect
# sed -i '/allow hal_audio_default init:unix_stream_socket connectto;/a\
# \
# # ViPER4Android\
# allow hal_audio_default hal_audio_default:process { execmem };' device/lge/msm8996-common/sepolicy/vendor/hal_audio_default.te
sed -i '/ro.hardware.egl=adreno \\/a\    ro.surface_flinger.supports_background_blur=1 \\' device/lge/msm8996-common/vendor_prop.mk
#cat device/lge/msm8996-common/vendor_prop.mk
KERNEL_DIR="kernel/lge/msm8996"
if ! grep -q "stendro_+_AShiningRay_+_continued_by_xc112lg" "$KERNEL_DIR/scripts/mkcompile_h"; then
  sed -i \
    -e '/if test -z "\$KBUILD_BUILD_USER"; then/,/^fi$/c\
LINUX_COMPILE_BY="stendro_+_AShiningRay_+_continued_by_xc112lg"' \
    -e '/if test -z "\$KBUILD_BUILD_HOST"; then/,/^fi$/c\
LINUX_COMPILE_HOST="crave.io"' \
    "$KERNEL_DIR/scripts/mkcompile_h"
fi


sed -i \
  -e '/<path name="headphones-hifi-dac">/a\        <ctl name="Es9218 Bypass" value="0" />' \
  -e '/<path name="headphones-hifi-dac-advanced">/a\        <ctl name="Es9218 Bypass" value="0" />' \
  -e '/<path name="headphones-hifi-dac-aux">/a\        <ctl name="Es9218 Bypass" value="0" />' \
  -e '/<path name="headphones-hifi-dacdop">/a\        <ctl name="Es9218 Bypass" value="0" />' \
  -e '/<path name="headphones-hifi-dacdop-advanced">/a\        <ctl name="Es9218 Bypass" value="0" />' \
  -e '/<path name="headphones-hifi-dacdop-aux">/a\        <ctl name="Es9218 Bypass" value="0" />' \
  device/lge/g6-common/audio/mixer_paths_tasha.xml
export BUILD_BCR=false
#export TARGET_INCLUDE_VIPERFX=true
export TARGET_ENABLE_BLUR=true
export WITH_ADB_INSECURE=true



sed -i '/<\/resources>/i\
\    <!-- Blur radius behind Notification Shade -->\n    <dimen name="max_shade_window_blur_radius">17dp</dimen>\n' "device/lge/msm8996-common/overlay/frameworks/base/packages/SystemUI/res/values/config.xml"


# Directory structure
mkdir -p device/lge/msm8996-common/rro_overlays/LauncherOverlayMsm8996/res/values

# Android.bp
cat > device/lge/msm8996-common/rro_overlays/LauncherOverlayMsm8996/Android.bp << 'EOF'
runtime_resource_overlay {
    name: "LauncherOverlayMsm8996",
    sdk_version: "current",
    vendor: true,
}
EOF

# AndroidManifest.xml
cat > device/lge/msm8996-common/rro_overlays/LauncherOverlayMsm8996/AndroidManifest.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<!--
     Copyright (C) 2025 PixelOS
     Copyright (C) 2025 LineageOS
     SPDX-License-Identifier: Apache-2.0
-->
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.android.launcher.overlay.msm8996">

    <overlay
        android:isStatic="true"
        android:priority="1"
        android:targetPackage="com.android.launcher3" />
</manifest>
EOF

# res/values/config.xml
cat > device/lge/msm8996-common/rro_overlays/LauncherOverlayMsm8996/res/values/config.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<!-- Copyright (C) 2018 The Android Open Source Project
     Licensed under the Apache License, Version 2.0 (the "License");
     you may not use this file except in compliance with the License.
     You may obtain a copy of the License at
        http://www.apache.org/licenses/LICENSE-2.0
     Unless required by applicable law or agreed to in writing, software
     distributed under the License is distributed on an "AS IS" BASIS,
     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
     See the License for the specific language governing permissions and
     limitations under the License.
-->
<resources>
    <dimen name="max_depth_blur_radius_enhanced">20dp</dimen>
</resources>
EOF

# Register in msm8996.mk
sed -i '/^    WifiOverlay \\$/a\    LauncherOverlayMsm8996 \\' device/lge/msm8996-common/msm8996.mk

sed -i '/^# Art$/i\
# ADB\
PRODUCT_PROPERTY_OVERRIDES += \\\
    persist.sys.usb.config=mtp,adb \\\
    persist.adb.tcp.port=5555\
' device/lge/msm8996-common/vendor_prop.mk

grep -q '^[[:space:]]*# props\.append("ro\.adb\.secure=1")' build/soong/scripts/gen_build_prop.py || sed -i '353s/^\([[:space:]]*\)props\.append("ro\.adb\.secure=1")/\1# props.append("ro.adb.secure=1")/' build/soong/scripts/gen_build_prop.py
grep -n -A2 -B2 'ro.adb.secure' build/soong/scripts/gen_build_prop.py
lunch lineage_h872-bp1a-userdebug
#lunch lineage_h872-bp4a-userdebug
# breakfast h872
make installclean

# brunch h872
m bacon



#lunch lineage_h872-bp4a-eng
#make installclean
#make clean # one time
#m bacon
#m evolution

#curl -sf https://raw.githubusercontent.com/xc112lg/evolutiion_lgg6/refs/heads/main/upevo.sh  | bash >/dev/null 2>&1
curl -sf https://raw.githubusercontent.com/xc112lg/testonly/refs/heads/main/testevo.sh  | bash >/dev/null 2>&1

#curl -sf https://raw.githubusercontent.com/xc112lg/evolutiion_lgg6/refs/heads/main/upkernel.sh  | bash

