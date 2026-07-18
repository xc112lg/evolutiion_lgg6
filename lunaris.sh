




rm -rf .repo/local_manifests/
rm -rf device/lge
rm -rf vendor/lge/msm8996-common
rm -rf vendor/evolution-priv/keys
ls vendor/evolution-priv/keys
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





# perl -0777 -pi -e 's/^cc_prebuilt_library_shared \{\n\tname: "libwifi-hal-ctrl",.*?\n\}\n\n?//ms' vendor/lge/msm8996-common/Android.bp
# sed -i 's/libbinder-v32/libbinder/g; s/libprotobuf-cpp-lite-v29/libprotobuf-cpp-lite/g' vendor/lge/msm8996-common/Android.bp
# sed -i '/name: "libkeystore_binder",/,/^	}/{
#   s/prefer: true,/prefer: true,\n\tcheck_elf_files: false,/
# }' vendor/lge/msm8996-common/Android.bp

perl -0777 -pi -e 's/^cc_prebuilt_library_shared \{\n\tname: "libwifi-hal-ctrl",.*?\n\}\n\n?//ms' vendor/lge/msm8996-common/Android.bp

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

sed -i \
  -e 's/^static void\* spkr_calibration_thread()$/static void* spkr_calibration_thread(void *context)/' \
  -e 's/^static void\* spkr_v_vali_thread()$/static void* spkr_v_vali_thread(void *context)/' \
  hardware/qcom-caf/msm8996/audio/hal/audio_extn/spkr_protection.c

sed -i '/LOCAL_MODULE       := init.radio.sh/,/include \$(BUILD_PREBUILT)/{
  s/LOCAL_VENDOR_MODULE    := true/LOCAL_VENDOR_MODULE    := true\nLOCAL_CHECK_ELF_FILES := false/
}' device/lge/g6-common/rootdir/Android.mk
git clone https://github.com/Evolution-X/vendor_evolution-priv_keys-template vendor/evolution-priv/keys
cd vendor/evolution-priv/keys
./keys.sh
cd -

sed -i '/^BOARD_CACHEIMAGE_PARTITION_SIZE/d; /^BOARD_USERDATAIMAGE_PARTITION_SIZE/d' device/lge/h872/BoardConfig.mk
#sed -i '$a -include vendor/evolution-priv/keys/keys.mk' device/lge/msm8996-common/msm8996.mk\

#lunch lineage_h872-bp1a-userdebug
lunch lineage_h872-bp4a-eng
make installclean
m evolution

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

curl -sf https://raw.githubusercontent.com/xc112lg/evolutiion_lgg6/refs/heads/main/upevo.sh  | bash >/dev/null 2>&1
