export WITH_GMS=false
export TARGET_USES_PICO_GAPPS=true
export BUILD_BCR=false
export TARGET_ENABLE_BLUR=true
export WITH_ADB_INSECURE=true
grep -q '^[[:space:]]*# props\.append("ro\.adb\.secure=1")' build/soong/scripts/gen_build_prop.py ||
sed -i 's/^\([[:space:]]*\)props\.append("ro\.adb\.secure=1")/\1# props.append("ro.adb.secure=1")/' build/soong/scripts/gen_build_prop.py
grep -n -A2 -B2 'ro.adb.secure' build/soong/scripts/gen_build_prop.py

lunch lineage_h872-bp1a-userdebug
#lunch lineage_h872-bp4a-userdebug
# breakfast h872
make installclean


m evolution

#curl -sf https://raw.githubusercontent.com/xc112lg/evolutiion_lgg6/refs/heads/main/upevo.sh  | bash >/dev/null 2>&1
curl -sf https://raw.githubusercontent.com/xc112lg/testonly/refs/heads/main/testevo.sh  | bash >/dev/null 2>&1

#curl -sf https://raw.githubusercontent.com/xc112lg/evolutiion_lgg6/refs/heads/main/upkernel.sh  | bash
