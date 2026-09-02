#!/bin/bash
set -e

# ================================================
# LG H872 KDZ -> DZ -> system.image -> Vendor blobs
# ================================================
#
# This script DOES NOT delete existing completed extraction data.
# Existing outputs are reused whenever possible.
#

ANDROID_ROOT="/tmp/src/android"

KDZTOOLS="$ANDROID_ROOT/kdztools"
KDZ_FILE="$ANDROID_ROOT/H87220g_00_1228.kdz"

KDZ_OUT="$ANDROID_ROOT/H87220g_extracted"
DZ_FILE="$KDZ_OUT/H87220g_00.dz"

PARTITIONS_OUT="$ANDROID_ROOT/H87220g_partitions"
SYSTEM_IMAGE="$PARTITIONS_OUT/system.image"

SYSTEM_DUMP="$ANDROID_ROOT/h872_system"
STOCK_DIR="$ANDROID_ROOT/h872_stock"

H872_TREE="$ANDROID_ROOT/device/lge/h872"

echo "=========================================="
echo " H872 KDZ Vendor Extraction"
echo "=========================================="
echo

# ------------------------------------------
# Check required files
# ------------------------------------------

if [ ! -f "$KDZ_FILE" ]; then
    echo "ERROR: KDZ file not found:"
    echo "  $KDZ_FILE"
    exit 1
fi

if [ ! -d "$KDZTOOLS" ]; then
    echo "ERROR: kdztools not found:"
    echo "  $KDZTOOLS"
    exit 1
fi

# ------------------------------------------
# Install dependencies
# ------------------------------------------

echo "[+] Installing dependencies..."

sudo apt update

sudo apt install -y \
    python3 \
    python3-pip \
    python3-venv \
    e2fsprogs \
    python3-zstandard

# ------------------------------------------
# Verify zstandard
# ------------------------------------------

if python3 -c "import zstandard" >/dev/null 2>&1; then
    echo "[+] Python zstandard module OK"
else
    echo "[!] python3-zstandard package did not provide zstandard."
    echo "[+] Trying pip..."

    python3 -m pip install --user zstandard

    if ! python3 -c "import zstandard" >/dev/null 2>&1; then
        echo "ERROR: Failed to install Python zstandard module!"
        exit 1
    fi
fi

# ------------------------------------------
# Install extract-utils only if missing
# ------------------------------------------

if [ ! -d "$ANDROID_ROOT/tools/extract-utils/.git" ]; then
    echo "[+] Installing LineageOS extract-utils..."

    mkdir -p "$ANDROID_ROOT/tools"

    if [ -d "$ANDROID_ROOT/tools/extract-utils" ]; then
        echo "[!] extract-utils directory exists but is not a git repository."
        echo "[!] Leaving it untouched to avoid deleting existing data."
        echo "[!] Please fix or remove it manually."
        exit 1
    fi

    git clone -b lineage-22.0 \
        https://github.com/LineageOS/android_tools_extract-utils.git \
        "$ANDROID_ROOT/tools/extract-utils"
else
    echo "[+] extract-utils already exists, skipping"
fi

# ------------------------------------------
# KDZ -> DZ
# ------------------------------------------

if [ ! -f "$DZ_FILE" ]; then
    echo
    echo "[+] Extracting KDZ..."

    mkdir -p "$KDZ_OUT"

    cd "$KDZTOOLS"

    python3 unkdz.py \
        -f "$KDZ_FILE" \
        -x \
        -d "$KDZ_OUT"
else
    echo
    echo "[+] DZ already exists, skipping KDZ extraction:"
    echo "    $DZ_FILE"
fi

# ------------------------------------------
# Verify DZ
# ------------------------------------------

if [ ! -f "$DZ_FILE" ]; then
    echo
    echo "ERROR: DZ file was not created!"
    echo "Expected:"
    echo "  $DZ_FILE"
    exit 1
fi

# ------------------------------------------
# DZ -> Partition images
# ------------------------------------------
#
# Do NOT delete existing partitions.
# Only extract if system.image is missing.
#

if [ ! -f "$SYSTEM_IMAGE" ]; then
    echo
    echo "[+] Extracting DZ partitions..."

    mkdir -p "$PARTITIONS_OUT"

    cd "$KDZTOOLS"

    python3 undz.py \
        -f "$DZ_FILE" \
        -s \
        -d "$PARTITIONS_OUT"
else
    echo
    echo "[+] system.image already exists."
    echo "[+] Skipping DZ extraction."
fi

# ------------------------------------------
# Verify system.image
# ------------------------------------------

if [ ! -f "$SYSTEM_IMAGE" ]; then
    echo
    echo "ERROR: system.image was not created!"
    echo
    echo "Current partition files:"
    ls -lah "$PARTITIONS_OUT" 2>/dev/null || true
    exit 1
fi

echo
echo "[+] system.image found:"
ls -lh "$SYSTEM_IMAGE"

echo
echo "[+] Checking filesystem type:"
file "$SYSTEM_IMAGE"

# ------------------------------------------
# system.image -> h872_stock
# ------------------------------------------
#
# Skip extraction if stock/system already exists.
# Do not delete existing completed stock extraction.
#

if [ ! -d "$STOCK_DIR/system" ]; then
    echo
    echo "[+] Extracting system.image with debugfs..."

    mkdir -p "$STOCK_DIR"

    # Only remove the temporary dump directory.
    # STOCK_DIR is NEVER deleted.
    if [ -d "$SYSTEM_DUMP" ]; then
        echo "[!] Removing old temporary dump:"
        echo "    $SYSTEM_DUMP"
        rm -rf "$SYSTEM_DUMP"
    fi

    mkdir -p "$SYSTEM_DUMP"

    debugfs -R "rdump / $SYSTEM_DUMP" "$SYSTEM_IMAGE"

    echo
    echo "[+] Moving extracted system to:"
    echo "    $STOCK_DIR/system"

    mv "$SYSTEM_DUMP" "$STOCK_DIR/system"

else
    echo
    echo "[+] Stock system already exists:"
    echo "    $STOCK_DIR/system"
    echo "[+] Skipping system.image extraction."
fi

# ------------------------------------------
# Verify system extraction
# ------------------------------------------

if [ ! -d "$STOCK_DIR/system" ]; then
    echo
    echo "ERROR: Stock system extraction failed!"
    echo "Missing:"
    echo "  $STOCK_DIR/system"
    exit 1
fi

# ------------------------------------------
# Create vendor symlink if missing
# ------------------------------------------

if [ ! -e "$STOCK_DIR/vendor" ] && [ ! -L "$STOCK_DIR/vendor" ]; then
    echo
    echo "[+] Creating vendor symlink..."

    ln -s system/vendor "$STOCK_DIR/vendor"
else
    echo
    echo "[+] Vendor path already exists:"
    ls -ld "$STOCK_DIR/vendor"
fi

# ------------------------------------------
# Verify stock extraction
# ------------------------------------------

echo
echo "[+] Stock directory:"
ls -la "$STOCK_DIR"

if [ -d "$STOCK_DIR/system/vendor" ]; then
    echo "[+] system/vendor exists"
else
    echo
    echo "[!] WARNING: system/vendor does not exist"
    echo "[!] Checking system contents:"
    ls -la "$STOCK_DIR/system" | head -50
fi

# ------------------------------------------
# Check H872 device tree
# ------------------------------------------

if [ ! -d "$H872_TREE" ]; then
    echo
    echo "ERROR: H872 device tree not found:"
    echo "  $H872_TREE"
    exit 1
fi

if [ ! -f "$H872_TREE/extract-files.sh" ]; then
    echo
    echo "ERROR: extract-files.sh not found:"
    echo "  $H872_TREE/extract-files.sh"
    exit 1
fi

# ------------------------------------------
# Extract proprietary blobs
# ------------------------------------------

echo
echo "=========================================="
echo "[+] Extracting proprietary blobs"
echo "=========================================="

cd "$H872_TREE"

chmod +x extract-files.sh

./extract-files.sh "$STOCK_DIR"

# ------------------------------------------
# Complete
# ------------------------------------------

echo
echo "=========================================="
echo " EXTRACTION COMPLETE!"
echo "=========================================="

echo
echo "KDZ:"
echo "  $KDZ_FILE"

echo
echo "DZ:"
echo "  $DZ_FILE"

echo
echo "Partition images:"
echo "  $PARTITIONS_OUT"

echo
echo "Stock dump:"
echo "  $STOCK_DIR"

echo
echo "Vendor blobs:"
echo "  $ANDROID_ROOT/vendor/lge"

echo
echo "Done!"
