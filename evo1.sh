export WITH_GMS=false
export TARGET_USES_PICO_GAPPS=true

source <(curl -sf https://raw.githubusercontent.com/xc112lg/scripts/refs/heads/lunaris/rbe8.sh)  >/dev/null 2>&1
source build/envsetup.sh

sed -i '4a type sensors_data_file, file_type, data_file_type;' device/lge/msm8996-common/sepolicy/vendor/file.te
cat  device/lge/msm8996-common/sepolicy/vendor/file.te


lunch lineage_h872-bp1a-user
#lunch lineage_h872-bp4a-userdebug
make installclean
m evolution

lunch lineage_h870-bp1a-user

make installclean
m evolution

lunch lineage_us997-bp1a-user

make installclean
m evolution

#lunch lineage_h872-bp4a-eng
#make installclean
#make clean # one time
#m bacon
#m evolution

curl -sf https://raw.githubusercontent.com/xc112lg/evolutiion_lgg6/refs/heads/main/upevo.sh  | bash >/dev/null 2>&1
