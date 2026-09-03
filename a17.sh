




rm -rf .repo/local_manifests/
rm -rf device/lge vendor/lineage-priv/keys
rm -rf vendor/lge/ kernel/lge/msm8996
rm -rf hardware/qcom-caf/msm8996
rm -rf hardware/qcom-caf/common 

#rm -rf out/target/product/*/obj/KERNEL_OBJ

#repo init -u https://github.com/crdroidandroid/android.git -b 16.0 --depth=1 --git-lf
repo init -u https://github.com/Evolution-X/manifest -b cnb --git-lfs --depth=1 
#repo init -u https://github.com/crdroidandroid/android.git -b 15.0 --git-lfs --depth=1
git clone https://github.com/xc112lg/local_manifests --depth 1 -b a18 .repo/local_manifests
# repo sync -c -j64 --force-sync --no-clone-bundle --optimized-fetch  --no-tags >/dev/null 2>&1
# /opt/crave/resync.sh
curl -sf https://raw.githubusercontent.com/xc112lg/lg_releases/refs/heads/main/resync.sh | bash
export WITH_GMS=false
export TARGET_USES_PICO_GAPPS=true
export BUILD_BCR=false
#export TARGET_INCLUDE_VIPERFX=true
export TARGET_ENABLE_BLUR=true
#export WITH_ADB_INSECURE=true


grep -q 'errno != EINVAL && errno != ENOSYS' bionic/libc/upstream-openbsd/android/include/arc4random.h && echo "already applied, skipping" || curl -sL https://raw.githubusercontent.com/xc112lg/evolutiion_lgg6/refs/heads/main/arc4random_wipeonfork1.patch | patch -p1

#sed -i '$a -include vendor/lineage-priv/keys/keys.mk' device/lge/msm8996-common/msm8996.mk

#perl -0777 -pi -e 's/^cc_prebuilt_library_shared \{\n\tname: "libwifi-hal-ctrl",.*?\n\}\n\n?//ms' vendor/lge/msm8996-common/Android.bp

grep -q '^[[:space:]]*# props\.append("ro\.adb\.secure=1")' build/soong/scripts/gen_build_prop.py ||
sed -i 's/^\([[:space:]]*\)props\.append("ro\.adb\.secure=1")/\1# props.append("ro.adb.secure=1")/' build/soong/scripts/gen_build_prop.py
#cat build/soong/scripts/gen_build_prop.py
export WITH_ADB_INSECURE=true
source <(curl -sf https://raw.githubusercontent.com/xc112lg/lg_releases/refs/heads/main/blur.sh)


if grep -q 'debug.SetMemoryLimit(40 \* 1024 \* 1024 \* 1024)' build/soong/cmd/soong_build/main.go; then
    echo "Soong memory limit patch already applied, skipping."
else
    curl -Ls https://github.com/yaap-17-stone/build_soong/commit/f9c27b0b9298f6eeee9a850346e0a646c3eaeb87.patch | \
        git -C build/soong am
fi

source build/envsetup.sh


lunch lineage_h872-cp2a-eng
#lunch lineage_h872-bp4a-userdebug
# breakfast h872
m evolution

# brunch h872
m bacon



#lunch lineage_h870d-bp4a-userdebug
#make installclean
#make clean # one time
#m bacon
#m evolution

#curl -sf https://raw.githubusercontent.com/xc112lg/evolutiion_lgg6/refs/heads/main/upevo.sh  | bash >/dev/null 2>&1
curl -sf https://raw.githubusercontent.com/xc112lg/testonly/refs/heads/main/testevo.sh  | bash >/dev/null 2>&1

#curl -sf https://raw.githubusercontent.com/xc112lg/evolutiion_lgg6/refs/heads/main/upkernel.sh  | bash
