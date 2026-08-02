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
