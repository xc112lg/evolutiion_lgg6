#!/bin/bash
set -e

ANDROID_ROOT="/tmp/src/android"
KDZ_FILE="${ANDROID_ROOT}/H87220g_00_1228.kdz"

KDZTOOLS="${ANDROID_ROOT}/kdztools"
EXTRACT_UTILS="${ANDROID_ROOT}/tools/extract-utils"

EXTRACTED="${ANDROID_ROOT}/H87220g_extracted"
PARTITIONS="${ANDROID_ROOT}/H87220g_partitions"
STOCK="${ANDROID_ROOT}/h872_stock"

echo "==> Installing dependencies..."
sudo apt update
sudo apt install -y git python3-venv python3-full e2fsprogs

cd "${ANDROID_ROOT}"

# Clone kdztools
if [ ! -d "${KDZTOOLS}" ]; then
    echo "==> Cloning kdztools..."
    git clone https://github.com/steadfasterX/kdztools.git "${KDZTOOLS}"
fi

# Install correct LineageOS extract-utils
echo "==> Installing LineageOS extract-utils..."
rm -rf "${EXTRACT_UTILS}"
git clone -b lineage-22.2 \
    https://github.com/LineageOS/android_tools_extract-utils.git \
    "${EXTRACT_UTILS}"

# Setup Python environment
cd "${KDZTOOLS}"

if [ ! -d "venv" ]; then
    echo "==> Creating Python virtual environment..."
    python3 -m venv venv
fi

echo "==> Installing Python dependencies..."
./venv/bin/pip install -U pip zstandard

# Check KDZ
if [ ! -f "${KDZ_FILE}" ]; then
    echo "ERROR: KDZ file not found:"
    echo "${KDZ_FILE}"
    exit 1
fi

mkdir -p "${EXTRACTED}" "${PARTITIONS}" "${STOCK}"

DZ_FILE="${EXTRACTED}/H87220g_00.dz"

# Extract KDZ
if [ ! -f "${DZ_FILE}" ]; then
    echo "==> Extracting KDZ..."
    python3 unkdz.py \
        -f "${KDZ_FILE}" \
        -x \
        -d "${EXTRACTED}"
else
    echo "==> DZ already exists, skipping KDZ extraction."
fi

SYSTEM_IMAGE="${PARTITIONS}/system.image"

# Extract DZ
if [ ! -f "${SYSTEM_IMAGE}" ]; then
    echo "==> Extracting DZ partitions..."
    ./venv/bin/python undz.py \
        -f "${DZ_FILE}" \
        -i \
        -d "${PARTITIONS}"
else
    echo "==> system.image already exists, skipping DZ extraction."
fi

echo "==> Checking system image..."
file "${SYSTEM_IMAGE}"

# Extract system filesystem
if [ ! -d "${STOCK}/app" ]; then
    echo "==> Extracting system filesystem with debugfs..."

    rm -rf "${STOCK}"
    mkdir -p "${STOCK}"

    debugfs -R "rdump / ${STOCK}" "${SYSTEM_IMAGE}"
else
    echo "==> Stock dump already exists, skipping system extraction."
fi

# Check H872 DT
H872_DT="${ANDROID_ROOT}/device/lge/h872"

if [ ! -d "${H872_DT}" ]; then
    echo "ERROR: H872 device tree not found:"
    echo "${H872_DT}"
    exit 1
fi

# Extract proprietary blobs
echo "==> Extracting proprietary blobs..."
cd "${H872_DT}"

./extract-files.sh "${STOCK}"

echo
echo "=========================================="
echo "DONE!"
echo "=========================================="
echo "KDZ:        ${KDZ_FILE}"
echo "DZ:         ${DZ_FILE}"
echo "Partitions: ${PARTITIONS}"
echo "Stock dump: ${STOCK}"
echo "Vendor:     ${ANDROID_ROOT}/vendor/lge"
