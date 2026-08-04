rm -rf .repo/local_manifests/
rm -rf device/lge
rm -rf vendor/lge/msm8996-common kernel/lge/msm8996
rm -rf vendor/bacon-priv/keys vendor/lineage-priv/keys
#rm -rf build/soong
#rm -rf out/target/product/*/obj/KERNEL_OBJ

#repo init -u https://github.com/crdroidandroid/android.git -b 16.0 --depth=1 --git-lfs
#repo init -u https://github.com/bacon-X/manifest -b bka --git-lfs --depth=1
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


#source <(curl -sf https://raw.githubusercontent.com/xc112lg/evolutiion_lgg6/refs/heads/main/rbe8.sh)  >/dev/null 2>&1

 mkdir -p device/lge/msm8996-common/overlay/frameworks/base/core/res/res/values
    curl -sf -o device/lge/msm8996-common/overlay/frameworks/base/core/res/res/values/cr_config.xml \
        https://raw.githubusercontent.com/crdroidandroid/android_frameworks_base/15.0/core/res/res/values/cr_config.xml

    mkdir -p device/lge/msm8996-common/overlay/frameworks/base/packages/SystemUI/res/values
    curl -sf -o device/lge/msm8996-common/overlay/frameworks/base/packages/SystemUI/res/values/cr_config.xml \
        https://raw.githubusercontent.com/crdroidandroid/android_frameworks_base/15.0/packages/SystemUI/res/values/cr_config.xml

source build/envsetup.sh



export WITH_GMS=false
export TARGET_USES_PICO_GAPPS=true
export BUILD_BCR=false
#export TARGET_INCLUDE_VIPERFX=true
export TARGET_ENABLE_BLUR=true
#export WITH_ADB_INSECURE=true

# grep -q '^[[:space:]]*# props\.append("ro\.adb\.secure=1")' build/soong/scripts/gen_build_prop.py ||
# sed -i 's/^\([[:space:]]*\)props\.append("ro\.adb\.secure=1")/\1# props.append("ro.adb.secure=1")/' build/soong/scripts/gen_build_prop.py


#sed -i 's/^BOARD_SEPOLICY_DIRS += \$(DEVICE_COMMON_PATH)\/sepolicy$/BOARD_VENDOR_SEPOLICY_DIRS += $(DEVICE_COMMON_PATH)\/sepolicy/' device/lge/g6-common/BoardConfigCommon.mk






curl -sL https://raw.githubusercontent.com/xc112lg/evolutiion_lgg6/refs/heads/main/init.qcom.usb.rc.patch | patch -d device/lge/msm8996-common -p0
source <(curl -sf https://raw.githubusercontent.com/xc112lg/evolutiion_lgg6/refs/heads/main/blur.sh)
source <(curl -sf https://raw.githubusercontent.com/xc112lg/evolutiion_lgg6/refs/heads/main/sepolicycrdfix.sh)
lunch lineage_h872-bp1a-userdebug

make installclean


m bacon


lunch lineage_h870-bp1a-userdebug
make installclean
m bacon

lunch lineage_us997-bp1a-userdebug
make installclean
m bacon

lunch lineage_h873-bp1a-userdebug
#lunch lineage_h872-bp4a-userdebug
make installclean
m bacon

lunch lineage_h870d-bp1a-userdebug

make installclean
m bacon



#curl -sf https://raw.githubusercontent.com/xc112lg/evolutiion_lgg6/refs/heads/main/upevo.sh  | bash >/dev/null 2>&1
curl -sf https://raw.githubusercontent.com/xc112lg/testonly/refs/heads/main/testevo.sh  | bash >/dev/null 2>&1

#curl -sf https://raw.githubusercontent.com/xc112lg/evolutiion_lgg6/refs/heads/main/upkernel.sh  | bash
