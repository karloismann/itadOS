#!/bin/bash

createConfig() {
    target="$1"
    cd "$target"
    
    lb config \
    --distribution bookworm \
    --iso-volume "ITADOS" \
    --image-name "itadOSv.0.1.1" \
    --architectures amd64 \
    --archive-areas "main contrib non-free non-free-firmware" \
    --binary-images iso-hybrid \
    --bootloader grub-efi \
    --debian-installer none \
    --bootappend-live "boot=live components username=root toram quiet splash"
}
