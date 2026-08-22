




rm -rf .repo/local_manifests/
rm -rf device/lge
rm -rf vendor/lge/msm8996-common kernel/lge/msm8996
rm -rf hardware/qcom-caf/msm8996
rm -rf hardware/qcom-caf/common

#rm -rf out/target/product/*/obj/KERNEL_OBJ

#repo init -u https://github.com/crdroidandroid/android.git -b 16.0 --depth=1 --git-lf
repo init -u https://github.com/crdroidandroid/android.git -b 16.0 --git-lfs --no-clone-bundle --depth=1 
#repo init -u https://github.com/crdroidandroid/android.git -b 15.0 --git-lfs --depth=1
git clone https://github.com/xc112lg/local_manifests --depth 1 -b lgcrd16 .repo/local_manifests
repo sync -c -j64 --force-sync --no-clone-bundle --optimized-fetch  --no-tags
/opt/crave/resync.sh

export WITH_GMS=false
export TARGET_USES_PICO_GAPPS=true
export BUILD_BCR=false
#export TARGET_INCLUDE_VIPERFX=true
export TARGET_ENABLE_BLUR=true
#export WITH_ADB_INSECURE=true


grep -q 'errno != EINVAL && errno != ENOSYS' bionic/libc/upstream-openbsd/android/include/arc4random.h && echo "already applied, skipping" || curl -sL https://raw.githubusercontent.com/xc112lg/evolutiion_lgg6/refs/heads/main/arc4random_wipeonfork1.patch | patch -p1

sed -i '$a -include vendor/lineage-priv/keys/keys.mk' device/lge/msm8996-common/msm8996.mk

#perl -0777 -pi -e 's/^cc_prebuilt_library_shared \{\n\tname: "libwifi-hal-ctrl",.*?\n\}\n\n?//ms' vendor/lge/msm8996-common/Android.bp

sed -i 's/libbinder-v32/libbinder/g; s/libprotobuf-cpp-lite-v29/libprotobuf-cpp-lite/g' vendor/lge/msm8996-common/Android.bp

sed -i '/name: "libkeystore_binder",/,/^}$/{
  s/prefer: true,/prefer: true,\n\tcheck_elf_files: false,/
}' vendor/lge/msm8996-common/Android.bp


sed -i '/name: "libwvdrmengine",/,/^}$/{
  s/prefer: true,/prefer: true,\n\tcheck_elf_files: false,/
}' vendor/lge/msm8996-common/Android.bp

sed -i '/name: "libwvhidl",/,/^}$/{
  s/prefer: true,/prefer: true,\n\tcheck_elf_files: false,/
}' vendor/lge/msm8996-common/Android.bp


sed -i '/LOCAL_MODULE       := init.radio.sh/,/include \$(BUILD_PREBUILT)/{
  s/LOCAL_VENDOR_MODULE    := true/LOCAL_VENDOR_MODULE    := true\nLOCAL_CHECK_ELF_FILES := false/
}' device/lge/g6-common/rootdir/Android.mk

sed -i '/# Add wlan to PRODUCT_SOONG_NAMESPACES/,/hardware\/qcom-caf\/wlan\/qcwcn/{
  /# Add wlan to PRODUCT_SOONG_NAMESPACES/i\
ifeq ($(BOARD_WLAN_DEVICE),qcwcn)
  /hardware\/qcom-caf\/wlan\/qcwcn$/a\
endif
}' hardware/qcom-caf/common/BoardConfigQcom.mk



source build/envsetup.sh






lunch lineage_h872-bp4a-eng
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
