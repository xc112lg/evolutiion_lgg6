




rm -rf .repo/local_manifests/
rm -rf device/lge
rm -rf vendor/lge/msm8996-common kernel/lge/msm8996
rm -rf vendor/evolution-priv/keys

#repo init -u https://github.com/crdroidandroid/android.git -b 16.0 --depth=1 --git-lfs
#repo init -u https://github.com/Evolution-X/manifest -b bka --git-lfs --depth=1
repo init -u https://github.com/Evolution-X/manifest -b vic --git-lfs --depth=1
git clone https://github.com/xc112lg/local_manifests --depth 1 -b lg .repo/local_manifests
repo sync -c -j32 --force-sync --no-clone-bundle --no-tags
/opt/crave/resync.sh
# export TARGET_USES_PICO_GAPPS=true
# export TARGET_ENABLE_BLUR=false
# export WITH_ADB_INSECURE=true
# export SELINUX_IGNORE_NEVERALLOWS=true
export WITH_GMS=false
export TARGET_USES_PICO_GAPPS=true
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


KBUSER=stendro_+_AShiningRay_+_continued_by_xc112lg
KBHOST=crave

export BUILD_USERNAME=$KBUSER
export BUILD_HOSTNAME=$KBHOST

export KBUILD_BUILD_USER=$KBUSER
export KBUILD_BUILD_HOST=$KBHOST


echo "USER=$KBUILD_BUILD_USER HOST=$KBUILD_BUILD_HOST"
echo "USER=$BUILD_USERNAME HOST=$BUILD_HOSTNAME"



sed -i 's/^SCO_WBS_SAMPLE_RATE = 0$/SCO_WBS_SAMPLE_RATE = 1/' device/lge/msm8996-common/bluetooth/vnd_lge_msm8996.txt

grep -q "BUILD_BROKEN_NINJA_USES_ENV_VARS" device/lge/msm8996-common/BoardConfigCommon.mk || \
cat >> device/lge/msm8996-common/BoardConfigCommon.mk << 'EOF'

BUILD_BROKEN_NINJA_USES_ENV_VARS := KBUILD_BUILD_USER KBUILD_BUILD_HOST BUILD_USERNAME BUILD_HOSTNAME
EOF

cat device/lge/msm8996-common/BoardConfigCommon.mk

rm -rf packages/apps/ViPER4AndroidFX
git clone https://github.com/TogoFire/packages_apps_ViPER4AndroidFX.git packages/apps/ViPER4AndroidFX

# 1. msm8996.mk — inherit the V4A product config
sed -i '/\$(call inherit-product, vendor\/lge\/msm8996-common\/msm8996-common-vendor.mk)/a\
\
# ViPER4Android\
$(call inherit-product, packages/apps/ViPER4AndroidFX/config.mk)' device/lge/msm8996-common/msm8996.mk

# 2. audio/audio_effects.xml — register the v4a_re library
sed -i '/<library name="volume_listener" path="libvolumelistener.so"\/>/a\
        <library name="v4a_re" path="libv4a_re.so"/>' device/lge/msm8996-common/audio/audio_effects.xml

# 3. audio/audio_effects.xml — register the v4a_standard_re effect
sed -i '/<effect name="notification_helper" library="volume_listener" uuid="0b776dde-0590-11e5-81ba-0025b32654a0"\/>/a\
        <effect name="v4a_standard_re" library="v4a_re" uuid="90380da3-8536-4744-a6a3-5731970e640f"/>' device/lge/msm8996-common/audio/audio_effects.xml

# 4. sepolicy/vendor/audioserver.te — file access + prop read
sed -i '/allow audioserver mpctl_socket:sock_file write;/a\
\
# ViPER4Android\
get_prop(audioserver, vendor_audio_prop)\
allow audioserver unlabeled:file { read write open getattr };' device/lge/msm8996-common/sepolicy/vendor/audioserver.te

# 5. sepolicy/vendor/hal_audio_default.te — execmem for the native effect
sed -i '/allow hal_audio_default init:unix_stream_socket connectto;/a\
\
# ViPER4Android\
allow hal_audio_default hal_audio_default:process { execmem };' device/lge/msm8996-common/sepolicy/vendor/hal_audio_default.te




lunch lineage_h872-bp1a-user
#lunch lineage_h872-bp4a-userdebug
make installclean
m evolution




#lunch lineage_h872-bp4a-eng
#make installclean
#make clean # one time
#m bacon
#m evolution

curl -sf https://raw.githubusercontent.com/xc112lg/evolutiion_lgg6/refs/heads/main/upevo.sh  | bash >/dev/null 2>&1
#curl -sf https://raw.githubusercontent.com/xc112lg/evolutiion_lgg6/refs/heads/main/upkernel.sh  | bash

