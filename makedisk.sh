#!/bin/bash

# -----------------------------------------------------------------------------
# SANCO CP/M 2.2 Disk Image Builder
#
# This script automates the process of:
#   - Preparing patched version of cpmtools for this platform
#   - Generating the boot track
#   - Patching SLF80037.COM (autoexec.bat) for a given locale
#   - Building final CP/M disk images with applications
#
# It creates three disk images by default: us, fr, it.
# -----------------------------------------------------------------------------

set -euo pipefail
IFS=$'\n\t'

# -----------------------------------------------------------------------------
# Globals and constants
# -----------------------------------------------------------------------------
SCRIPT_DIR=$(dirname `realpath $0`) # Base directory where the script is run
TMPFILES=()                         # Track temp files for cleanup
CPMTOOLS_PREFIX=""                  # Set by prepare_cpmtools()

# Applications to be copied into the CP/M disk
# CORE = code that has been reversed and can be assembled from source
CORE_APPS=(COPY8003.COM FUNK00.COM PAR8003.COM SG8003.COM TRX62.COM)
# EXTRA = all additional software that is not yet reversed (in this repo) or
# we don't want to reverse
# Applications from Digital Research
EXTRA_APPS=(ASM.COM DDT.COM DUMP.COM LOAD.COM PIP.COM STAT.COM SUBMIT.COM XSUB.COM)
# Useful applications not from Digital Research
EXTRA_APPS+=(ED.COM MBASIC.COM)
# Specific applications for Ceda/Sanco that we have not yet reversed
EXTRA_APPS+=(RCX62.COM TERM80.COM FMT8003.COM CONFIG80.COM)

# -----------------------------------------------------------------------------
# Helpers
# -----------------------------------------------------------------------------

# Clean up temporary files on exit
cleanup() {
    if [[ ${#TMPFILES[@]} -gt 0 ]]; then
        rm -rf -- "${TMPFILES[@]}"
    fi
}
trap cleanup EXIT

# Allocate a new temporary file or directory and track it for later cleanup
# Return: sets TMP with the generated temporary path
new_tmp() {
    TMP=$(mktemp "$@")
    TMPFILES+=("$TMP")
}

# Simple logger for progress messages
log() {
    echo -e "==> $*" >&2
}

# Validate the locale to avoid invalid filenames or missing resources
validate_locale() {
    case "$1" in
        us|fr|it) ;;
        *) echo "Invalid locale: $1" >&2; exit 1;;
    esac
}

# -----------------------------------------------------------------------------
# Prepare cpmtools (clone, patch, build)
# -----------------------------------------------------------------------------
prepare_cpmtools() {
    if [[ ! -d cpmtools ]]; then
        log "Cloning cpmtools repository..."
        git clone https://github.com/lipro-cpm4l/cpmtools.git
    fi

    pushd cpmtools > /dev/null

    if [[ ! -f .patched ]]; then
        log "Applying local patch to cpmtools..."
        git reset --hard   # ensure clean tree before patch
        git apply ../patch/0001-feat-added-capability-to-handle-images-with-multiple.patch
        touch .patched
    fi

    if [[ ! -f mkfs.cpm ]]; then
        log "Building cpmtools..."
        ./configure
        make -j"$(nproc)" all
        touch .built
    fi

    popd > /dev/null

    # Set the base path for the patched version of cpmtools
    CPMTOOLS_PREFIX="$SCRIPT_DIR/cpmtools/"
}

# -----------------------------------------------------------------------------
# Generate boot track from CPM components
# Return: sets BOOTTRACK variable pointing to the temporary boot track file
# that will be copied into the final disk image
# -----------------------------------------------------------------------------
genboottrack() {
    log "Generating boot track..."
    local boottrack
    new_tmp
    boottrack=$TMP

    make -C cpm build/cpm_bios.bin build/cpm_loader.bin > /dev/null

    # Manually cut-and-paste parts of the CP/M components to assemble the boot track
    # See README.md for more info about the boot track format
    dd conv=notrunc oflag=append status=none bs=256 if=cpm/build/cpm_loader.bin of="$boottrack"
    dd conv=notrunc oflag=append status=none skip=3072 bs=1 count=512 if=cpm/cpm_bdos.bin of="$boottrack"
    dd conv=notrunc oflag=append status=none bs=256 count=13 if=cpm/build/cpm_bios.bin of="$boottrack"
    dd conv=notrunc oflag=append status=none bs=1024 count=2 if=cpm/cpm_ccp.bin of="$boottrack"
    dd conv=notrunc oflag=append status=none bs=1024 count=3 if=cpm/cpm_bdos.bin of="$boottrack"

    BOOTTRACK="$boottrack"
}

# -----------------------------------------------------------------------------
# Patch SLF80037.COM with keyboard map + locale string
# Return: sets SLF variable pointing to the temporary SLF80037.COM file that
# will be copied into the final disk image
# -----------------------------------------------------------------------------
patchslf() {
    local locale=$1
    log "Patching SLF80037.COM for locale=$locale..."
    local slf80037
    new_tmp
    slf80037=$TMP

    make -C applications build/SLF80037.COM > /dev/null
    cp applications/build/SLF80037.COM "$slf80037"

    # Patch keyboard layout
    dd conv=notrunc bs=1 seek=7424 status=none \
        if="applications/localization/keymap_${locale}.bin" of="$slf80037"

    # Patch 2-letter locale string at offset 303
    echo -n "$locale" | dd conv=notrunc,ucase bs=1 count=2 seek=303 status=none of="$slf80037"

    SLF="$slf80037"
}

# -----------------------------------------------------------------------------
# Build one disk image for the given locale
# -----------------------------------------------------------------------------
makedisk() {
    local locale=$1
    validate_locale "$locale"
    local filename="disks/SANCO-CPM22_${locale}.bin"

    log "Building disk image: $filename"

    mkdir -p "$(dirname "$filename")"
    rm -f "$filename"

    # Generate boot track
    genboottrack
    "$CPMTOOLS_PREFIX"mkfs.cpm -f sanco -b "$BOOTTRACK" "$filename"

    # Patch SLF80037.COM "autoexec" with the requested locale file
    patchslf "$locale"
    "$CPMTOOLS_PREFIX"cpmcp -f sanco "$filename" "$SLF" 0:SLF80037.COM

    # Add core applications
    log "Adding core applications..."
    make -C applications assemble > /dev/null
    for comfile in "${CORE_APPS[@]}"; do
        "$CPMTOOLS_PREFIX"cpmcp -f sanco "$filename" "applications/build/$comfile" 0:
    done

    # Add extra applications copied from reference image
    log "Adding extra applications..."
    local apptmp
    new_tmp -d
    apptmp=$TMP
    for comfile in "${EXTRA_APPS[@]}"; do
        "$CPMTOOLS_PREFIX"cpmcp -f sanco SANCO8003_CPM_2.2fr.bin 0:"$comfile" "$apptmp/$comfile"
        "$CPMTOOLS_PREFIX"cpmcp -f sanco "$filename" "$apptmp/$comfile" 0:
    done
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
prepare_cpmtools

for loc in us fr it; do
    makedisk "$loc"
done

log "All disk images were successfully built!"
