export WITH_GMS=false
export TARGET_USES_PICO_GAPPS=true

source <(curl -sf https://raw.githubusercontent.com/xc112lg/scripts/refs/heads/lunaris/rbe8.sh)  >/dev/null 2>&1
source build/envsetup.sh

mkdir -p device/lge/msm8996-common/sepolicy/vendor-user
if [ ! -f device/lge/msm8996-common/sepolicy/vendor-user/file.te ]; then
    echo 'type sensors_data_file, file_type, data_file_type;' > device/lge/msm8996-common/sepolicy/vendor-user/file.te
fi
grep -q "sepolicy/vendor-user" device/lge/msm8996-common/BoardConfigCommon.mk || cat >> device/lge/msm8996-common/BoardConfigCommon.mk << 'EOF'

ifeq ($(TARGET_BUILD_VARIANT),user)
BOARD_VENDOR_SEPOLICY_DIRS += $(COMMON_PATH)/sepolicy/vendor-user
endif
EOF

lunch lineage_h870-bp1a-user

make installclean
m evolution

lunch lineage_us997-bp1a-user

make installclean
m evolution

lunch lineage_h873-bp1a-user
#lunch lineage_h872-bp4a-userdebug
make installclean
m evolution

lunch lineage_h870d-bp1a-user

make installclean
m evolution
#lunch lineage_h872-bp4a-eng
#make installclean
#make clean # one time
#m bacon
#m evolution

curl -sf https://raw.githubusercontent.com/xc112lg/evolutiion_lgg6/refs/heads/main/upevo.sh  | bash >/dev/null 2>&1
