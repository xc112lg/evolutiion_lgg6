




rm -rf .repo/local_manifests/

#repo init -u https://github.com/crdroidandroid/android.git -b 16.0 --depth=1 --git-lfs
repo init -u https://github.com/Evolution-X/manifest -b bka --git-lfs --depth=1
# repo init -u https://github.com/Evolution-X/manifest -b vic --git-lfs --depth=1
git clone https://github.com/xc112lg/local_manifests --depth 1 -b lg2 .repo/local_manifests
repo sync -c -j32 --force-sync --no-clone-bundle --no-tags
/opt/crave/resync.sh
# export TARGET_USES_PICO_GAPPS=true
# export TARGET_ENABLE_BLUR=false
# export WITH_ADB_INSECURE=true
# export SELINUX_IGNORE_NEVERALLOWS=true
export WITH_GMS=false
export TARGET_USES_PICO_GAPPS=true
export CLANG_TARGET_ARM32="--target=arm-linux-android"

source <(curl -sf https://raw.githubusercontent.com/xc112lg/scripts/refs/heads/lunaris/rbe8.sh)  >/dev/null 2>&1
source build/envsetup.sh





perl -0777 -pi -e 's/^cc_prebuilt_library_shared \{\n\tname: "libwifi-hal-ctrl",.*?\n\}\n\n?//ms' vendor/lge/msm8996-common/Android.bp
sed -i 's/libbinder-v32/libbinder/g; s/libprotobuf-cpp-lite-v29/libprotobuf-cpp-lite/g' vendor/lge/msm8996-common/Android.bp
sed -i '/^vendor\/lib\/libwifi-hal-ctrl\.so|/s/^/-/' device/lge/msm8996-common/proprietary-files.txt
sed -i '/^vendor\/lib64\/libwifi-hal-ctrl\.so|/s/^/-/' device/lge/msm8996-common/proprietary-files.txt
sed -i '/vendor\/lineage\/config\/device_framework_matrix.xml/d; s|hardware/qcom-caf/common/vendor_framework_compatibility_matrix_legacy.xml \\|hardware/qcom-caf/common/vendor_framework_compatibility_matrix_legacy.xml|' device/lge/msm8996-common/BoardConfigCommon.mk

sed -i '/<\/compatibility-matrix>/i\
    <hal format="hidl" optional="true">\
        <name>vendor.lineage.livedisplay</name>\
        <version>2.0</version>\
        <interface>\
            <name>IPictureAdjustment</name>\
            <instance>default</instance>\
        </interface>\
    </hal>\
    <hal format="aidl" optional="true">\
        <name>vendor.lineage.health</name>\
        <interface>\
            <name>IChargingControl</name>\
            <instance>default</instance>\
        </interface>\
    </hal>' device/lge/msm8996-common/framework_compatibility_matrix.xml

#lunch lineage_h872-bp1a-userdebug
lunch lineage_h872-bp4a-userdebug


make installclean
m bacon

# lunch lineage_h870-bp1a-userdebug

# make installclean
# m evolution -j64

# lunch lineage_us997-bp1a-userdebug

# make installclean
# m evolution -j64

#lunch lineage_h872-bp4a-eng
#make installclean
#make clean # one time
#m bacon
#m evolution


