#!/bin/bash
# Applies the recovery-source patches for gta4lve decrypt support.
# Run from the root of your TWRP/OrangeFox source tree:
#   bash device/samsung/gta4lve/patches/apply_patches.sh
# Safe to run more than once (already-applied patches are skipped).
TOP="${ANDROID_BUILD_TOP:-$PWD}"
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$TOP/bootable/recovery"
[ -d "$REPO/.git" ] || [ -f "$REPO/.git" ] || { echo "bootable/recovery not found under $TOP"; exit 1; }
for p in "$DIR"/bootable_recovery/*.patch; do
    name="$(basename "$p")"
    if git -C "$REPO" apply --reverse --check "$p" 2>/dev/null; then
        echo "already applied: $name"
    elif git -C "$REPO" apply --check "$p" 2>/dev/null; then
        git -C "$REPO" apply "$p" && echo "applied: $name"
    else
        echo "FAILED (does not apply cleanly - your recovery source differs): $name"
        exit 1
    fi
done
