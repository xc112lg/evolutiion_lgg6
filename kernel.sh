
sed -i '$a -include vendor/evolution-priv/keys/keys.mk' device/lge/msm8996-common/msm8996.mk

mkdir -p device/lge/msm8996-common/sepolicy/vendor-user
if [ ! -f device/lge/msm8996-common/sepolicy/vendor-user/file.te ]; then
    echo 'type sensors_data_file, file_type, data_file_type;' > device/lge/msm8996-common/sepolicy/vendor-user/file.te
fi
grep -q "sepolicy/vendor-user" device/lge/msm8996-common/BoardConfigCommon.mk || cat >> device/lge/msm8996-common/BoardConfigCommon.mk << 'EOF'

ifeq ($(TARGET_BUILD_VARIANT),user)
BOARD_VENDOR_SEPOLICY_DIRS += $(COMMON_PATH)/sepolicy/vendor-user
endif
EOF

#sed -i '4a type sensors_data_file, file_type, data_file_type;' device/lge/msm8996-common/sepolicy/vendor/file.te
cat  device/lge/msm8996-common/sepolicy/vendor/file.te

#source <(curl -sf https://raw.githubusercontent.com/xc112lg/scripts/refs/heads/lunaris/rbe8.sh)  >/dev/null 2>&1
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
export BUILD_USERNAME=stendro_+_AShiningRay_+_continued_by_xc112lg
export BUILD_HOSTNAME=crave.io


sed -i 's/^SCO_WBS_SAMPLE_RATE = 0$/SCO_WBS_SAMPLE_RATE = 1/' device/lge/msm8996-common/bluetooth/vnd_lge_msm8996.txt
lunch lineage_h872-bp1a-user
#lunch lineage_h872-bp4a-userdebug
make installclean
export NINJA_ARGS="-j1"
export USE_GOMA=false
export USE_RBE=false
make recovery -j1




#lunch lineage_h872-bp4a-eng
#make installclean
#make clean # one time
#m bacon
#m evolution

curl -sf https://raw.githubusercontent.com/xc112lg/evolutiion_lgg6/refs/heads/main/upevo.sh  | bash >/dev/null 2>&1
#curl -sf https://raw.githubusercontent.com/xc112lg/evolutiion_lgg6/refs/heads/main/upkernel.sh  | bash

