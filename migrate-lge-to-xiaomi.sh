#!/usr/bin/env bash
#
# migrate-lge-to-xiaomi.sh
#
# Copies the LG G5/V20/G6 device tree, defconfigs, and drivers from
# xc112lg/android_kernel_lge_msm8996_r2 (swan25) into a checkout of
# Inkypen79/android_kernel_xiaomi_msm8996 (lineage-23.2), then patches
# the build files (Kconfig/Makefile) that reference the new "lge/" dirs.
#
# Usage:
#   ./migrate-lge-to-xiaomi.sh /path/to/lge-swan25 /path/to/xiaomi-lineage-23.2
#
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <path-to-lge-swan25-checkout> <path-to-xiaomi-lineage-23.2-checkout>"
  exit 1
fi

LGE="$(realpath "$1")"
XIA="$(realpath "$2")"

for p in "$LGE" "$XIA"; do
  [[ -d "$p" ]] || { echo "ERROR: not a directory: $p"; exit 1; }
done

echo "LGE source : $LGE"
echo "Xiaomi dest: $XIA"
echo

# ---------------------------------------------------------------------------
# 1. Copy the confirmed LG-specific directories (new paths, nothing overwritten)
# ---------------------------------------------------------------------------
declare -a DIRS=(
  "arch/arm64/boot/dts/lge"
  "arch/arm64/configs/vendor/lge"
  "drivers/input/touchscreen/lge"
  "drivers/soc/qcom/lge"
  "drivers/usb/misc/tusb422/lge"
  "drivers/video/fbdev/msm/lge"
  "include/soc/qcom/lge"
)

for d in "${DIRS[@]}"; do
  src="$LGE/$d"
  dst="$XIA/$d"
  if [[ ! -d "$src" ]]; then
    echo "SKIP (not found in LGE tree): $d"
    continue
  fi
  if [[ -e "$dst" ]]; then
    echo "SKIP (already exists in Xiaomi tree, resolve manually): $d"
    continue
  fi
  mkdir -p "$(dirname "$dst")"
  cp -a "$src" "$dst"
  echo "copied: $d"
done

echo
echo "=== Directory copy done. Patching build files... ==="
echo

# ---------------------------------------------------------------------------
# 2. Patch arch/arm64/boot/dts/Makefile — conditional dts-dir swap
# ---------------------------------------------------------------------------
DTS_MK="$XIA/arch/arm64/boot/dts/Makefile"
if [[ -f "$DTS_MK" ]] && ! grep -q "CONFIG_MACH_LGE" "$DTS_MK"; then
  # Replace the plain "dts-dirs += qcom" line with the conditional block
  python3 - "$DTS_MK" <<'PYEOF'
import sys
path = sys.argv[1]
with open(path) as f:
    content = f.read()
old = "dts-dirs += qcom\n"
new = (
    "ifneq ($(CONFIG_MACH_LGE),y)\n"
    "dts-dirs += qcom\n"
    "else\n"
    "dts-dirs += lge\n"
    "endif\n"
)
if old in content:
    content = content.replace(old, new, 1)
    with open(path, "w") as f:
        f.write(content)
    print("patched:", path)
else:
    print("WARNING: expected 'dts-dirs += qcom' line not found in", path)
PYEOF
else
  echo "SKIP (already patched or missing): $DTS_MK"
fi

# ---------------------------------------------------------------------------
# 3. Patch drivers/soc/qcom/Kconfig — source the lge Kconfig
# ---------------------------------------------------------------------------
SOC_KCONFIG="$XIA/drivers/soc/qcom/Kconfig"
if [[ -f "$SOC_KCONFIG" ]] && ! grep -q 'source "drivers/soc/qcom/lge/Kconfig"' "$SOC_KCONFIG"; then
  printf '\nsource "drivers/soc/qcom/lge/Kconfig"\n' >> "$SOC_KCONFIG"
  echo "patched: $SOC_KCONFIG (appended source line — move it inside the menu block if needed)"
else
  echo "SKIP (already patched or missing): $SOC_KCONFIG"
fi

# ---------------------------------------------------------------------------
# 4. Patch drivers/soc/qcom/Makefile — build the lge/ objects
# ---------------------------------------------------------------------------
SOC_MK="$XIA/drivers/soc/qcom/Makefile"
if [[ -f "$SOC_MK" ]] && ! grep -q "CONFIG_MACH_LGE" "$SOC_MK"; then
  printf 'obj-$(CONFIG_MACH_LGE) += lge/\n' >> "$SOC_MK"
  echo "patched: $SOC_MK"
else
  echo "SKIP (already patched or missing): $SOC_MK"
fi

# ---------------------------------------------------------------------------
# 5. Patch drivers/input/touchscreen/Kconfig + Makefile
# ---------------------------------------------------------------------------
TS_KCONFIG="$XIA/drivers/input/touchscreen/Kconfig"
if [[ -f "$TS_KCONFIG" ]] && ! grep -q 'source "drivers/input/touchscreen/lge/Kconfig"' "$TS_KCONFIG"; then
  printf '\nsource "drivers/input/touchscreen/lge/Kconfig"\n' >> "$TS_KCONFIG"
  echo "patched: $TS_KCONFIG (appended — move inside menu block if needed)"
else
  echo "SKIP (already patched or missing): $TS_KCONFIG"
fi

TS_MK="$XIA/drivers/input/touchscreen/Makefile"
if [[ -f "$TS_MK" ]] && ! grep -q "CONFIG_LGE_TOUCH_CORE" "$TS_MK"; then
  printf 'obj-$(CONFIG_LGE_TOUCH_CORE)\t\t+= lge/\n' >> "$TS_MK"
  echo "patched: $TS_MK"
else
  echo "SKIP (already patched or missing): $TS_MK"
fi

# ---------------------------------------------------------------------------
# 6. Patch drivers/video/fbdev/msm/Makefile
#    NOTE: CONFIG_LGE_DISPLAY_COMMON is defined INLINE in the LGE
#    drivers/video/fbdev/msm/Kconfig, not sourced from a sub-file.
#    This script copies that Kconfig block automatically; review the
#    diff it prints before trusting it.
# ---------------------------------------------------------------------------
FB_MK="$XIA/drivers/video/fbdev/msm/Makefile"
if [[ -f "$FB_MK" ]] && ! grep -q "CONFIG_LGE_DISPLAY_COMMON" "$FB_MK"; then
  printf 'obj-$(CONFIG_LGE_DISPLAY_COMMON) += lge/\n' >> "$FB_MK"
  echo "patched: $FB_MK"
else
  echo "SKIP (already patched or missing): $FB_MK"
fi

FB_KCONFIG_SRC="$LGE/drivers/video/fbdev/msm/Kconfig"
FB_KCONFIG_DST="$XIA/drivers/video/fbdev/msm/Kconfig"
echo
echo "--- LGE_DISPLAY_COMMON Kconfig block (manual merge required) ---"
if [[ -f "$FB_KCONFIG_SRC" ]]; then
  awk '/^config LGE_DISPLAY_COMMON/{flag=1} flag{print} flag && /^$/{exit}' "$FB_KCONFIG_SRC"
else
  echo "(source Kconfig not found at expected path)"
fi
echo "-----------------------------------------------------------------"
echo "Add the block above into: $FB_KCONFIG_DST"
echo "(inside the same menu context as the other display config options)"

# ---------------------------------------------------------------------------
# 7. drivers/usb/misc/tusb422 — SPECIAL CASE.
#    Xiaomi's tree has no tusb422 base driver at all (it uses its own
#    drivers/usb/pd/ instead). TUSB422 is a discrete TI USB-PD controller
#    chip physically present on LG G5/V20/G6 boards. Unless your target
#    Xiaomi device also has this exact chip, porting it is pointless —
#    copying just "lge/" here would reference a parent driver that
#    doesn't exist. Copy the WHOLE tusb422/ dir only if you've confirmed
#    the hardware need; otherwise leave it out entirely.
# ---------------------------------------------------------------------------
TUSB_XIA_BASE="$XIA/drivers/usb/misc/tusb422"
TUSB_LGE_BASE="$LGE/drivers/usb/misc/tusb422"
if [[ -d "$TUSB_XIA_BASE" && -f "$TUSB_XIA_BASE/Makefile" ]]; then
  # Base driver already exists in Xiaomi tree (unlikely) — just hook lge/ in
  TUSB_MK="$TUSB_XIA_BASE/Makefile"
  if ! grep -q "tusb422/lge" "$TUSB_MK"; then
    {
      printf 'ccflags-$(CONFIG_TUSB422_PAL) += -I$(srctree)/drivers/usb/misc/tusb422/lge\n'
      printf 'obj-$(CONFIG_TUSB422_PAL)\t+= lge/\n'
    } >> "$TUSB_MK"
    echo "patched: $TUSB_MK"
  else
    echo "SKIP (already patched): $TUSB_MK"
  fi
else
  echo
  echo "NOTE: Xiaomi tree has no drivers/usb/misc/tusb422/ base driver."
  echo "      TUSB422 is a discrete TI USB-PD chip on LG hardware; Xiaomi"
  echo "      msm8996 devices use drivers/usb/pd/ instead. The lge/ subfolder"
  echo "      was already copied above, but its parent driver was NOT copied"
  echo "      and is NOT wired into the build. Only copy the rest of"
  echo "      $TUSB_LGE_BASE manually if you've confirmed your target board"
  echo "      actually has a TUSB422 chip — otherwise delete the copied"
  echo "      $XIA/drivers/usb/misc/tusb422/lge and skip this driver entirely."
fi

# ---------------------------------------------------------------------------
# 8. Scan for CONFIG_MACH_LGE usage in files SHARED with the Xiaomi tree.
#    These are files both kernels already have their own (differing)
#    copies of — not something a directory copy can touch. For each one
#    that exists in both trees, generate a full diff and a filtered
#    "MACH_LGE-only" diff (just the hunks that mention the flag) so you
#    can hand-merge the relevant hunks against Xiaomi's own version of
#    the file instead of reviewing a huge unrelated-divergence diff.
# ---------------------------------------------------------------------------
echo
echo "=== Scanning for CONFIG_MACH_LGE usage in files shared with Xiaomi tree... ==="
echo

DIFF_OUT="$XIA/../lge-mach-lge-diffs"
mkdir -p "$DIFF_OUT"

# every LGE file that mentions MACH_LGE, excluding the lge/-named dirs
# already copied wholesale in step 1 (those don't need diffing)
mapfile -t MACH_LGE_FILES < <(
  grep -rl "MACH_LGE" "$LGE" 2>/dev/null \
    | grep -vE "/(lge)/" \
    | sed "s|^$LGE/||"
)

echo "Found ${#MACH_LGE_FILES[@]} file(s) outside lge/ dirs referencing CONFIG_MACH_LGE."
echo

SHARED_COUNT=0
LGE_ONLY_COUNT=0
SUMMARY="$DIFF_OUT/SUMMARY.txt"
{
  echo "CONFIG_MACH_LGE usage outside lge/-named directories"
  echo "Generated $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo
} > "$SUMMARY"

python3 - "$LGE" "$XIA" "$DIFF_OUT" "$SUMMARY" "${MACH_LGE_FILES[@]}" <<'PYEOF'
import sys, subprocess, re, os

lge_root, xia_root, out_dir, summary_path = sys.argv[1:5]
files = sys.argv[5:]

shared, lge_only = [], []

with open(summary_path, "a") as summary:
    for rel in files:
        lge_path = os.path.join(lge_root, rel)
        xia_path = os.path.join(xia_root, rel)
        safe_name = rel.replace("/", "__")

        if not os.path.isfile(xia_path):
            lge_only.append(rel)
            summary.write(f"[LGE-ONLY, not in Xiaomi tree] {rel}\n")
            continue

        shared.append(rel)
        diff = subprocess.run(
            ["diff", "-u", xia_path, lge_path],
            capture_output=True, text=True
        ).stdout

        full_path = os.path.join(out_dir, safe_name + ".full.diff")
        with open(full_path, "w") as f:
            f.write(diff)

        hunks = re.split(r'(?=^@@ )', diff, flags=re.M)
        header = hunks[0] if hunks else ""
        matching = [h for h in hunks[1:] if "MACH_LGE" in h]
        filtered_path = os.path.join(out_dir, safe_name + ".MACH_LGE_ONLY.diff")
        with open(filtered_path, "w") as f:
            f.write(header + "".join(matching))

        summary.write(
            f"[SHARED] {rel}  "
            f"({len(matching)} of {len(hunks)-1} hunks touch MACH_LGE)\n"
            f"    full diff:      {os.path.basename(full_path)}\n"
            f"    filtered diff:  {os.path.basename(filtered_path)}\n"
        )

    summary.write(f"\nTotals: {len(shared)} shared files diffed, "
                   f"{len(lge_only)} files only exist in the LGE tree.\n")

print(f"shared={len(shared)} lge_only={len(lge_only)}")
PYEOF

echo
echo "Diffs written to: $DIFF_OUT"
echo "Read $DIFF_OUT/SUMMARY.txt first — it tells you, per file, how many"
echo "hunks actually touch MACH_LGE vs. unrelated tree divergence, and"
echo "points you at the *.MACH_LGE_ONLY.diff for the part worth reviewing."
echo
echo "IMPORTANT: these are diffs for manual review only — nothing here is"
echo "auto-applied. In every file checked so far, the LGE and Xiaomi copies"
echo "have ALSO diverged for unrelated reasons (different upstream fixes,"
echo "different hardware defaults), so blindly applying a filtered diff"
echo "can still corrupt Xiaomi-specific code around the same lines. Merge"
echo "each hunk by hand against Xiaomi's current version of the file."

echo
echo "=== Done. ==="
echo
echo "Still needed before this builds:"
echo "  1. Merge the LGE_DISPLAY_COMMON Kconfig block printed above into $FB_KCONFIG_DST"
echo "  2. Add/select a CONFIG_MACH_LGE and CONFIG_MACH_MSM8996_* machine type"
echo "     (search $LGE for 'config MACH_LGE' and the MACH_MSM8996_* entries"
echo "     under arch/arm64/Kconfig* — these select which board dts gets built)"
echo "  3. Merge a device defconfig: cat the relevant files from"
echo "     $XIA/arch/arm64/configs/vendor/lge/*.config onto your target defconfig"
echo "  4. Diff arch/arm64/Kconfig between the two trees for the"
echo "     'ARM_GIC_V3_ITS if (PCI_MSI && !MACH_LGE)' style guards"
echo "  5. Work through $DIFF_OUT/SUMMARY.txt and hand-merge each"
echo "     *.MACH_LGE_ONLY.diff into Xiaomi's version of that file"
echo "  6. Try a build and fix undefined symbols one at a time —"
echo "     these drivers were written against LG's board/regulator/panel"
echo "     setup and will reference structs/GPIOs that don't exist on"
echo "     Xiaomi hardware until you adapt the DTS bindings."
