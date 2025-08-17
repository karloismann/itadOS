#!/bin/bash

itadOS="itadOSv.0.1.1"
config="./itadOSLiveBuild/config"
myListChroot="./livebuildFiles/my.list.chroot"
bashrc="./livebuildFiles/.bashrc"
logind="./livebuildFiles/logind.conf"
isolinux="./livebuildFiles/isolinux.cfg"
grub="./livebuildFiles/grub.cfg"

createEnviroment() {
    # Create directory for itadOS
    mkdir ./itadOSLiveBuild

    # create config
    ./config.sh

    # Move itadOS into live-build
    mkdir -p "${config}"/includes.chroot && mv ./"${itadOS}" "${config}"/includes.chroot

    # Give itadOS execution permission
    chmod +x "${config}"/includes.chroot/itadOSv.0.1.1/main.sh

    # Move dependency list to live-build
    mv "${myListChroot}" "${config}"/package-lists/

    # Move .bashrc to live-build
    mkdir -p "${config}"/root && mv "${bashrc}" "${config}"/root

    # Move logind to live-build
    mkdir -p "${config}"/includes.chroot/etc/systemd && mv "${logind}" "${config}"/includes.chroot/etc/systemd

    # Move ioslinux to live-build
    mkdir -p "${config}"/includes.binary/isolinux && mv "${isolinux}" "${config}"/includes.binary/isolinux

    # Copy COM32 modules to live-build
    cp /usr/lib/syslinux/modules/bios/*.c32 "${config}"/includes.binary/isolinux

    # Move grub to live-build
    mkdir -p "${config}"/includes.binary/boot/grub && mv "${grub}" "${config}"/includes.binary/boot/grub
}
