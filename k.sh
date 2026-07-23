#!/bin/bash
set -e

# ==========================================================================
# LOW-RAM OPTIMIZATIONS (no swap available)
# ==========================================================================
# Swap isn't usable here (container/VPS restriction, or by choice), so the
# only lever is keeping peak memory usage down. Real constraints to know:
#   - The Soong/Kati dependency-graph analysis phase loads as one fixed
#     block BEFORE compiling starts, and is NOT reduced by -j. If your
#     container's memory limit is below what this phase needs (can be
#     several GB on a LineageOS tree), it will OOM regardless of job count.
#   - The compile/link phase DOES scale with -j (already minimized below).

# Cap the separate "highmem" pool Soong uses for expensive single actions
# (kotlin/metalava/R8/dexing) independently of the general job pool -
# these are some of the biggest single-job memory spikes in the tree.
export NINJA_HIGHMEM_NUM_JOBS=1

# Print whatever memory limit the container/cgroup actually has, so you
# know up front whether this is even feasible before burning build time.
if [ -f /sys/fs/cgroup/memory.max ]; then
    echo "Cgroup memory limit: $(cat /sys/fs/cgroup/memory.max)"
elif [ -f /sys/fs/cgroup/memory/memory.limit_in_bytes ]; then
    echo "Cgroup memory limit: $(cat /sys/fs/cgroup/memory/memory.limit_in_bytes)"
fi

# ==========================================================================
# Original device/sepolicy setup
# ==========================================================================
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

cat device/lge/msm8996-common/sepolicy/vendor/file.te

# NOTE: sourcing remote scripts (curl | source / curl | bash) runs arbitrary
# code with your full shell privileges. Keep doing this only if you trust
# and control this repo — consider pinning a commit hash instead of a
# branch ref (refs/heads/lunaris) so a future push can't silently change
# what runs on your machine.
source <(curl -sf https://raw.githubusercontent.com/xc112lg/scripts/refs/heads/lunaris/rbe8.sh) >/dev/null 2>&1
source build/envsetup.sh

export BUILD_USERNAME=stendro_+_AShiningRay_+_continued_by_xc112lg
export BUILD_HOSTNAME=crave.io

sed -i 's/^SCO_WBS_SAMPLE_RATE = 0$/SCO_WBS_SAMPLE_RATE = 1/' device/lge/msm8996-common/bluetooth/vnd_lge_msm8996.txt

lunch lineage_h872-bp1a-user
make installclean

# ==========================================================================
# LOW-RAM OPTIMIZATIONS (build parallelism)
# ==========================================================================
# - Keep everything at a single canonical job count instead of setting it
#   in two different places (env var + explicit -j flag), which is
#   confusing and can drift out of sync.
# - Explicitly disable ccache if you're this RAM-constrained: ccache speeds
#   up *rebuilds* but does nothing for a first build, and its hash/compress
#   step adds a bit of extra memory pressure per job. Remove this line if
#   you plan to build repeatedly and have disk space to spare.
export USE_CCACHE=0
export USE_GOMA=false
export USE_RBE=false

JOBS=1
export NINJA_ARGS="-j${JOBS} -l$((JOBS * 2))"   # -l caps scheduling when load avg gets high, extra safety net
export SOONG_UI_NINJA_ARGS="-j${JOBS}"

make recovery -j${JOBS}

curl -sf https://raw.githubusercontent.com/xc112lg/evolutiion_lgg6/refs/heads/main/upevo.sh | bash >/dev/null 2>&1
#curl -sf https://raw.githubusercontent.com/xc112lg/evolutiion_lgg6/refs/heads/main/upkernel.sh | bash
