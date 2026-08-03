############################
#Precompiled Build wont take much time
###########################
export WITH_GMS=false
export TARGET_USES_PICO_GAPPS=true
export BUILD_BCR=false
export TARGET_ENABLE_BLUR=true
export WITH_ADB_INSECURE=true
grep -q '^[[:space:]]*# props\.append("ro\.adb\.secure=1")' build/soong/scripts/gen_build_prop.py ||
sed -i 's/^\([[:space:]]*\)props\.append("ro\.adb\.secure=1")/\1# props.append("ro.adb.secure=1")/' build/soong/scripts/gen_build_prop.py
grep -n -A2 -B2 'ro.adb.secure' build/soong/scripts/gen_build_prop.py

#source <(curl -sf https://raw.githubusercontent.com/xc112lg/scripts/refs/heads/lunaris/rbe8.sh)  >/dev/null 2>&1
source build/envsetup.sh

lunch lineage_h872-bp1a-user
make installclean
m evolution

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
#m evolutionss

curl -sf https://raw.githubusercontent.com/xc112lg/evolutiion_lgg6/refs/heads/main/upevo.sh  | bash >/dev/null 2>&1
