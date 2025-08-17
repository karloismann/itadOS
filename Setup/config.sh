#!/bin/bash

lb config \
--distribution bookworm \
--architectures amd64 \
--archive-areas "main contrib non-free non-free-firmware" \
--binary-images iso-hybrid \
--bootloader grub-efi \
--debian-installer none \
--bootappend-live "boot=live components username=root toram quiet splash"
