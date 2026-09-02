#!/bin/bash
#
# LG H872 KDZ -> stock files -> LineageOS vendor extraction
#

set -e

ANDROID_ROOT="/tmp/src/android"

KDZ_FILE="${ANDROID_ROOT}/H87220g_00_1228.kdz"

KDZTOOLS="${ANDROID_ROOT}/kdztools"
KDZ_OUT="${ANDROID_ROOT}/H87220g_extracted"
DZ_OUT="${ANDROID_ROOT}/H87220g_partitions"
STOCK_OUT="${ANDROID_ROOT}/h872_stock"

DEVICE_TREE="${ANDROID_ROOT}/device/lge/msm8996-common"
EXTRACT_UTILS="${ANDROID_ROOT}/tools/extract-utils"

DEVICE="h872"
DEVICE_COMMON="g6-common"
PLATFORM_COMMON="msm8996-common"
VENDOR="lge"

echo "========================================"
echo " LG H872 Vendor Extraction"
echo "========================================"

cd "${ANDROID_ROOT}"

#
# Check KDZ
#
if [ ! -f "${KDZ_FILE}" ]; then
    echo "ERROR: KDZ not found:"
    echo "${KDZ_FILE}"
    exit 1
fi

#
# Install Python dependencies
#
echo ""
echo "==> Installing Python dependencies..."

sudo apt install -y python3-venv python3-full

if [ ! -d "${KDZTOOLS}" ]; then
    echo "ERROR: kdztools directory not found:"
    echo "${KDZTOOLS}"
    exit 1
fi

cd "${KDZTOOLS}"

if [ ! -d venv ]; then
    python3 -m venv venv
fi

"${KDZTOOLS}/venv/bin/pip" install --upgrade pip
"${KDZTOOLS}/venv/bin/pip" install zstandard

PYTHON="${KDZTOOLS}/venv/bin/python"

#
# Extract KDZ -> DZ
#
DZ_FILE="${KDZ_OUT}/H87220g_00.dz"

if [ ! -f "${DZ_FILE}" ]; then
    echo ""
    echo "==> Extracting KDZ..."

    mkdir -p "${KDZ_OUT}"

    "${PYTHON}" unkdz.py \
        -f "${KDZ_FILE}" \
        -x \
        -d "${KDZ_OUT}"
else
    echo ""
    echo "==> DZ already exists, skipping KDZ extraction:"
    echo "${DZ_FILE}"
fi

#
# Extract DZ -> partition images
#
SYSTEM_IMAGE="${DZ_OUT}/system.image"

if [ ! -f "${SYSTEM_IMAGE}" ]; then
    echo ""
    echo "==> Extracting DZ partitions..."

    mkdir -p "${DZ_OUT}"

    "${PYTHON}" undz.py \
        -f "${DZ_FILE}" \
        -i \
        -d "${DZ_OUT}"
else
    echo ""
    echo "==> system.image already exists."
    echo "==> Skipping DZ extraction."
fi

#
# Check system.image
#
if [ ! -f "${SYSTEM_IMAGE}" ]; then
    echo "ERROR: system.image was not created!"
    exit 1
fi

echo ""
echo "==> Found:"
file "${SYSTEM_IMAGE}"

#
# Recreate stock directory
#
echo ""
echo "==> Preparing stock directory..."

rm -rf "${STOCK_OUT}"
mkdir -p "${STOCK_OUT}"

#
# Extract ext4 system.image without mounting
#
echo ""
echo "==> Dumping system.image..."

sudo apt install -y e2tools

if command -v debugfs >/dev/null 2>&1; then

    echo "Using debugfs..."

    sudo debugfs \
        -R "rdump / ${STOCK_OUT}" \
        "${SYSTEM_IMAGE}" || true

else
    echo "ERROR: debugfs not found"
    exit 1
fi

#
# Fix ownership
#
echo ""
echo "==> Fixing ownership..."

sudo chown -R "$(id -u):$(id -g)" "${STOCK_OUT}" || true

#
# Clone correct extract-utils
#
echo ""
echo "==> Installing LineageOS extract-utils..."

cd "${ANDROID_ROOT}"

rm -rf tools/extract-utils

git clone \
    -b lineage-22.2 \
    https://github.com/LineageOS/android_tools_extract-utils.git \
    tools/extract-utils

#
# Check device tree
#
if [ ! -d "${DEVICE_TREE}" ]; then
    echo "ERROR: Device tree not found:"
    echo "${DEVICE_TREE}"
    exit 1
fi

#
# Check H872 wrapper tree
#
H872_TREE="${ANDROID_ROOT}/device/lge/h872"

if [ ! -d "${H872_TREE}" ]; then
    echo ""
    echo "WARNING: H872 device tree not found:"
    echo "${H872_TREE}"
    echo ""
    echo "The common msm8996 blobs can still be extracted,"
    echo "but device-specific H872 extraction may be missing."
fi

#
# Extract common proprietary blobs
#
echo ""
echo "========================================"
echo " Extracting proprietary blobs"
echo "========================================"

cd "${DEVICE_TREE}"

# The msm8996-common script expects these variables.
export DEVICE_COMMON="${DEVICE_COMMON}"
export PLATFORM_COMMON="${PLATFORM_COMMON}"
export VENDOR="${VENDOR}"

#
# Extract platform common blobs
#
echo ""
echo "==> Extracting msm8996-common blobs..."

bash ./extract-files.sh "${STOCK_OUT}"

echo ""
echo "========================================"
echo " DONE"
echo "========================================"

echo ""
echo "Stock dump:"
echo "  ${STOCK_OUT}"

echo ""
echo "Partition images:"
echo "  ${DZ_OUT}"

echo ""
echo "Vendor blobs should now be under:"
echo "  ${ANDROID_ROOT}/vendor/lge/"
