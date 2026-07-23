# lunch lineage_h872-bp1a-userdebug
# #lunch lineage_h872-bp4a-userdebug
# make installclean
# m evolution
KBUSER=stendro_+_AShiningRay_+_continued_by_xc112lg
KBHOST=crave

export BUILD_USERNAME=$KBUSER
export BUILD_HOSTNAME=$KBHOST

export KBUILD_BUILD_USER=$KBUSER
export KBUILD_BUILD_HOST=$KBHOST


echo "USER=$KBUILD_BUILD_USER HOST=$KBUILD_BUILD_HOST"
echo "USER=$BUILD_USERNAME HOST=$BUILD_HOSTNAME"




source build/envsetup.sh
# lunch lineage_h870-bp1a-userdebug

# make installclean
# m evolution

# lunch lineage_us997-bp1a-userdebug

# make installclean
# m evolution

echo "USER=$BUILD_USERNAME HOST=$BUILD_HOSTNAME"

KBUSER=stendro_+_AShiningRay_+_continued_by_xc112lg
KBHOST=crave

export BUILD_USERNAME=$KBUSER
export BUILD_HOSTNAME=$KBHOST

export KBUILD_BUILD_USER=$KBUSER
export KBUILD_BUILD_HOST=$KBHOST


echo "USER=$KBUILD_BUILD_USER HOST=$KBUILD_BUILD_HOST"
echo "USER=$BUILD_USERNAME HOST=$BUILD_HOSTNAME"

sed -i 's/^SCO_WBS_SAMPLE_RATE = 0$/SCO_WBS_SAMPLE_RATE = 1/' device/lge/msm8996-common/bluetooth/vnd_lge_msm8996.txt
lunch lineage_h872-bp1a-user

echo "USER=$KBUILD_BUILD_USER HOST=$KBUILD_BUILD_HOST"
echo "USER=$BUILD_USERNAME HOST=$BUILD_HOSTNAME"


#lunch lineage_h872-bp4a-userdebug





#lunch lineage_h872-bp4a-eng
#make installclean
#make clean # one time
#m bacon
#m evolution

curl -sf https://raw.githubusercontent.com/xc112lg/evolutiion_lgg6/refs/heads/main/upevo.sh  | bash >/dev/null 2>&1
#curl -sf https://raw.githubusercontent.com/xc112lg/evolutiion_lgg6/refs/heads/main/upkernel.sh  | bash

