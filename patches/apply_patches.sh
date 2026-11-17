#!/bin/bash
# Applies the source patches for gta4lve decrypt support.
# Run from the root of your TWRP/OrangeFox source tree:
#   bash device/samsung/gta4lve/patches/apply_patches.sh
# Safe to run more than once (already-applied patches are skipped).
TOP="${ANDROID_BUILD_TOP:-$PWD}"
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

declare -A REPOS=(
    [bootable_recovery]="bootable/recovery"
    [system_vold]="system/vold"
)

for d in "${!REPOS[@]}"; do
    REPO="$TOP/${REPOS[$d]}"
    [ -d "$DIR/$d" ] || continue
    [ -d "$REPO/.git" ] || [ -f "$REPO/.git" ] || { echo "${REPOS[$d]} not found under $TOP"; exit 1; }
    for p in "$DIR/$d"/*.patch; do
        name="$d/$(basename "$p")"
        if git -C "$REPO" apply --reverse --check "$p" 2>/dev/null; then
            echo "already applied: $name"
        elif git -C "$REPO" apply --check "$p" 2>/dev/null; then
            git -C "$REPO" apply "$p" && echo "applied: $name"
        else
            echo "FAILED (does not apply cleanly - your source differs): $name"
            exit 1
        fi
    done
done
