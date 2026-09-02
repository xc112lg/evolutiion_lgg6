#!/bin/bash
set -e

ANDROID_ROOT="/tmp/src/android"
KDZ_FILE="${ANDROID_ROOT}/H87220g_00_1228.kdz"

KDZTOOLS="${ANDROID_ROOT}/kdztools"
EXTRACTED="${ANDROID_ROOT}/H87220g_extracted"
PARTITIONS="${ANDROID_ROOT}/H87220g_partitions"
STOCK="${ANDROID_ROOT}/h872_stock"

echo "==> Installing dependencies..."
sudo apt update
sudo apt install -y git python3-venv python3-full e2fsprogs

cd "${ANDROID_ROOT}"

if [ ! -d "${KDZTOOLS}" ]; then
    echo "==> Cloning kdztools..."
    git clone https://github.com/steadfasterX/kdztools.git "${KDZTOOLS}"
fi

cd "${KDZTOOLS}"

if [ ! -d "venv" ]; then
    echo "==> Creating Python virtual environment..."
    python3 -m venv venv
fi

echo "==> Installing Python dependencies..."
./venv/bin/pip install -U pip zstandard

if [ ! -f "${KDZ_FILE}" ]; then
    echo "ERROR: KDZ file not found:"
    echo "${KDZ_FILE}"
    exit 1
fi

mkdir -p "${EXTRACTED}"
mkdir -p "${PARTITIONS}"
mkdir -p "${STOCK}"

DZ_FILE="${EXTRACTED}/H87220g_00.dz"

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

if [ ! -d "${STOCK}/system" ] && [ ! -d "${STOCK}/vendor" ]; then
    echo "==> Extracting system filesystem with debugfs..."
    debugfs -R "rdump / ${STOCK}" "${SYSTEM_IMAGE}"
else
    echo "==> Stock dump already exists, skipping system extraction."
fi

H872_DT="${ANDROID_ROOT}/device/lge/h872"

if [ ! -d "${H872_DT}" ]; then
    echo "ERROR: H872 device tree not found:"
    echo "${H872_DT}"
    exit 1
fi

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
