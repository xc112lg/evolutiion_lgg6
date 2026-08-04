rm -rf .repo/local_manifests/
rm -rf device/lge
rm -rf vendor/lge/msm8996-common kernel/lge/msm8996
rm -rf vendor/evolution-priv/keys vendor/lineage-priv/keys
rm -rf build/soong
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
source <(curl -sf https://raw.githubusercontent.com/xc112lg/evolutiion_lgg6/refs/heads/main/rbe8.sh)  >/dev/null 2>&1

 mkdir -p device/lge/msm8996-common/overlay/frameworks/base/core/res/res/values
    curl -sf -o device/lge/msm8996-common/overlay/frameworks/base/core/res/res/values/cr_config.xml \
        https://raw.githubusercontent.com/crdroidandroid/android_frameworks_base/15.0/core/res/res/values/cr_config.xml

    mkdir -p device/lge/msm8996-common/overlay/frameworks/base/packages/SystemUI/res/values
    curl -sf -o device/lge/msm8996-common/overlay/frameworks/base/packages/SystemUI/res/values/cr_config.xml \
        https://raw.githubusercontent.com/crdroidandroid/android_frameworks_base/15.0/packages/SystemUI/res/values/cr_config.xml

source build/envsetup.sh


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

export BUILD_BCR=false
#export TARGET_INCLUDE_VIPERFX=true
export TARGET_ENABLE_BLUR=true
#export WITH_ADB_INSECURE=true
\

#sed -i 's/^BOARD_SEPOLICY_DIRS += \$(DEVICE_COMMON_PATH)\/sepolicy$/BOARD_VENDOR_SEPOLICY_DIRS += $(DEVICE_COMMON_PATH)\/sepolicy/' device/lge/g6-common/BoardConfigCommon.mk


grep -q '^[[:space:]]*# props\.append("ro\.adb\.secure=1")' build/soong/scripts/gen_build_prop.py ||
sed -i 's/^\([[:space:]]*\)props\.append("ro\.adb\.secure=1")/\1# props.append("ro.adb.secure=1")/' build/soong/scripts/gen_build_prop.py


sed -i '$r /dev/stdin' device/lge/msm8996-common/sepolicy/vendor/file_contexts <<'EOF'

# ODM sepolicy fragments
# AOSP's private/file_contexts only matches /(odm|vendor/odm)/etc/selinux/...
# On this device there is no separate /vendor partition (merged into
# /system/vendor), so the real runtime path is /system/vendor/odm/etc/selinux/...
# which falls outside that pattern and was falling back to the generic
# vendor_file label, causing zygote/installd/system_server (and adb shell)
# to be denied getattr/read on these files. Types below match AOSP's own
# per-file types (see system/sepolicy private/file_contexts) exactly.
/system/vendor/odm/etc/selinux/odm_file_contexts                 u:object_r:file_contexts_file:s0
/system/vendor/odm/etc/selinux/odm_seapp_contexts                u:object_r:seapp_contexts_file:s0
/system/vendor/odm/etc/selinux/odm_property_contexts             u:object_r:property_contexts_file:s0
/system/vendor/odm/etc/selinux/odm_service_contexts              u:object_r:vendor_service_contexts_file:s0
/system/vendor/odm/etc/selinux/odm_hwservice_contexts            u:object_r:hwservice_contexts_file:s0
/system/vendor/odm/etc/selinux/odm_mac_permissions\.xml          u:object_r:mac_perms_file:s0
/system/vendor/odm/etc/selinux/odm_sepolicy\.cil                 u:object_r:sepolicy_file:s0
EOF

cat device/lge/msm8996-common/sepolicy/vendor/file_contexts

mkdir -p device/lge/msm8996-common/sepolicy/vendor-user
if [ ! -f device/lge/msm8996-common/sepolicy/vendor-user/file.te ]; then
    echo 'type sensors_data_file, file_type, data_file_type;' > device/lge/msm8996-common/sepolicy/vendor-user/file.te
fi
grep -q "sepolicy/vendor-user" device/lge/msm8996-common/BoardConfigCommon.mk || cat >> device/lge/msm8996-common/BoardConfigCommon.mk << 'EOF'

ifeq ($(TARGET_BUILD_VARIANT),user)
BOARD_VENDOR_SEPOLICY_DIRS += $(COMMON_PATH)/sepolicy/vendor-user
endif
EOF


#curl -sL https://raw.githubusercontent.com/xc112lg/evolutiion_lgg6/refs/heads/main/init.qcom.usb.rc.patch | patch -d device/lge/msm8996-common -p0

lunch lineage_h872-bp1a-user

make installclean


m bacon


#curl -sf https://raw.githubusercontent.com/xc112lg/evolutiion_lgg6/refs/heads/main/upevo.sh  | bash >/dev/null 2>&1
curl -sf https://raw.githubusercontent.com/xc112lg/testonly/refs/heads/main/testevo.sh  | bash >/dev/null 2>&1

#curl -sf https://raw.githubusercontent.com/xc112lg/evolutiion_lgg6/refs/heads/main/upkernel.sh  | bash
