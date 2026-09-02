#!/bin/bash
set -e

# ================================================

# LG H872 KDZ -> DZ -> system.image -> Vendor blobs

# Python extract-utils version

# ================================================

#

# This script does NOT delete existing completed extraction data.

# Existing outputs are reused whenever possible.

#

ANDROID_ROOT="/tmp/src/android"

KDZTOOLS="$ANDROID_ROOT/kdztools"
KDZ_FILE="$ANDROID_ROOT/H87220g_00_1228.kdz"

KDZ_OUT="$ANDROID_ROOT/H87220g_extracted"
DZ_FILE="$KDZ_OUT/H93220s_00.dz"

PARTITIONS_OUT="$ANDROID_ROOT/H87220g_partitions"
SYSTEM_IMAGE="$PARTITIONS_OUT/system.image"

SYSTEM_DUMP="$ANDROID_ROOT/h872_system"
STOCK_DIR="$ANDROID_ROOT/h872_stock"

H872_TREE="$ANDROID_ROOT/device/lge/h872"

echo "=========================================="
echo " H872 KDZ Vendor Extraction"
echo " Python extract-utils version"
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

if [ ! -d "$H872_TREE" ]; then
echo "ERROR: H872 device tree not found:"
echo "  $H872_TREE"
exit 1
fi

if [ ! -f "$H872_TREE/extract-files.py" ]; then
echo "ERROR: extract-files.py not found:"
echo "  $H872_TREE/extract-files.py"
exit 1
fi

# ------------------------------------------

# Check extract-utils

# ------------------------------------------

EXTRACT_UTILS="$ANDROID_ROOT/tools/extract-utils"

if [ ! -d "$EXTRACT_UTILS" ]; then
echo
echo "ERROR: extract-utils not found:"
echo "  $EXTRACT_UTILS"
exit 1
fi

if [ ! -f "$EXTRACT_UTILS/extract_utils/main.py" ]; then
echo
echo "WARNING: Could not find:"
echo "  $EXTRACT_UTILS/extract_utils/main.py"
echo
echo "Make sure your extract-utils migration is installed correctly."
fi

# ------------------------------------------

# Install dependencies

# ------------------------------------------

echo
echo "[+] Installing dependencies..."

sudo apt update

sudo apt install -y 
python3 
python3-pip 
python3-venv 
e2fsprogs 
python3-zstandard

# ------------------------------------------

# Verify zstandard

# ------------------------------------------

if python3 -c "import zstandard" >/dev/null 2>&1; then
echo "[+] Python zstandard module OK"
else
echo "[!] python3-zstandard package did not provide zstandard."
echo "[+] Trying pip..."

```
python3 -m pip install --user zstandard

if ! python3 -c "import zstandard" >/dev/null 2>&1; then
    echo "ERROR: Failed to install Python zstandard module!"
    exit 1
fi
```

fi

# ------------------------------------------

# KDZ -> DZ

# ------------------------------------------

if [ ! -f "$DZ_FILE" ]; then
echo
echo "[+] Extracting KDZ..."

```
mkdir -p "$KDZ_OUT"

cd "$KDZTOOLS"

python3 unkdz.py \
    -f "$KDZ_FILE" \
    -x \
    -d "$KDZ_OUT"
```

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
echo
echo "Expected:"
echo "  $DZ_FILE"
echo
echo "Files extracted from KDZ:"
ls -lah "$KDZ_OUT" 2>/dev/null || true
exit 1
fi

# ------------------------------------------

# DZ -> Partition images

# ------------------------------------------

if [ ! -f "$SYSTEM_IMAGE" ]; then
echo
echo "[+] Extracting DZ partitions..."

```
mkdir -p "$PARTITIONS_OUT"

cd "$KDZTOOLS"

python3 undz.py \
    -f "$DZ_FILE" \
    -s \
    -d "$PARTITIONS_OUT"
```

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

# The Python extract-files.py script expects a

# source directory containing system/vendor.

#

if [ ! -d "$STOCK_DIR/system" ]; then
echo
echo "[+] Extracting system.image with debugfs..."

```
mkdir -p "$STOCK_DIR"

# Only remove temporary extraction data.
# Do NOT remove STOCK_DIR.
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
```

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
echo
echo "Missing:"
echo "  $STOCK_DIR/system"
exit 1
fi

# ------------------------------------------

# Create vendor symlink if missing

# ------------------------------------------

if [ ! -e "$STOCK_DIR/vendor" ] && [ ! -L "$STOCK_DIR/vendor" ]; then
echo
echo "[+] Creating vendor -> system/vendor symlink..."

```
ln -s system/vendor "$STOCK_DIR/vendor"
```

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

# Extract proprietary blobs

# ------------------------------------------

echo
echo "=========================================="
echo "[+] Extracting proprietary blobs"
echo "=========================================="
echo

cd "$H872_TREE"

# Python extract-utils extraction.

#

# The H872 extract-files.py should handle its

# common device trees if device_with_commons()

# is configured in the Python migration.

python3 extract-files.py "$STOCK_DIR"

# ------------------------------------------

# Verify extraction result

# ------------------------------------------

VENDOR_LGE="$ANDROID_ROOT/vendor/lge"

echo
if [ -d "$VENDOR_LGE" ]; then
echo "[+] Vendor directory exists:"
echo "    $VENDOR_LGE"
else
echo "[!] WARNING: Vendor directory was not found:"
echo "    $VENDOR_LGE"
fi

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
echo "  $VENDOR_LGE"

echo
echo "Done!"
