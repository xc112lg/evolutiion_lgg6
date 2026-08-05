export WITH_GMS=false
export TARGET_USES_PICO_GAPPS=true
export BUILD_BCR=false
#export TARGET_INCLUDE_VIPERFX=true
export TARGET_ENABLE_BLUR=true
#export WITH_ADB_INSECURE=true
#source <(curl -sf https://raw.githubusercontent.com/xc112lg/evolutiion_lgg6/refs/heads/main/blur.sh)  >/dev/null 2>&1
#sed -i '$a -include vendor/evolution-priv/keys/keys.mk' device/lge/msm8996-common/msm8996.mk
source build/envsetup.sh
#curl -sL https://raw.githubusercontent.com/xc112lg/evolutiion_lgg6/refs/heads/main/init.qcom.usb.rc.patch | patch -d device/lge/msm8996-common -p0 || true
lunch lineage_h872-bp1a-userdebug
make installclean
m evolution
lunch lineage_h870-bp1a-userdebug
make installclean
m evolution
lunch lineage_us997-bp1a-userdebug
make installclean
m evolution
lunch lineage_h873-bp1a-userdebug
make installclean
m evolution
lunch lineage_h870d-bp1a-userdebug
make installclean
m evolution
#curl -sf https://raw.githubusercontent.com/xc112lg/evolutiion_lgg6/refs/heads/main/upevo.sh  | bash >/dev/null 2>&1
curl -sf https://raw.githubusercontent.com/xc112lg/testonly/refs/heads/main/testevo.sh  | bash >/dev/null 2>&1
#curl -sf https://raw.githubusercontent.com/xc112lg/evolutiion_lgg6/refs/heads/main/upkernel.sh  | bash
