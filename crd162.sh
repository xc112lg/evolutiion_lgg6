


export WITH_GMS=false
export TARGET_USES_PICO_GAPPS=true
export BUILD_BCR=false
#export TARGET_INCLUDE_VIPERFX=true
export TARGET_ENABLE_BLUR=true
#export WITH_ADB_INSECURE=true
export GOMEMLIMIT=22GiB
export GOGC=50




source build/envsetup.sh






lunch lineage_h872-bp4a-userdebug
#lunch lineage_h872-bp4a-userdebug
# breakfast h872
make installclean

# brunch h872
m bacon -j4



#lunch lineage_h872-bp4a-eng
#make installclean
#make clean # one time
#m bacon
#m evolution

#curl -sf https://raw.githubusercontent.com/xc112lg/evolutiion_lgg6/refs/heads/main/upevo.sh  | bash >/dev/null 2>&1
curl -sf https://raw.githubusercontent.com/xc112lg/testonly/refs/heads/main/testevo.sh  | bash >/dev/null 2>&1

#curl -sf https://raw.githubusercontent.com/xc112lg/evolutiion_lgg6/refs/heads/main/upkernel.sh  | bash
