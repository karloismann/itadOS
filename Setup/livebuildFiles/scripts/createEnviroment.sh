#!/bin/bash

itadOS="itadOSv.0.1.1"
config="./itadOSLiveBuild/config"
myListChroot="./livebuildFiles/my.list.chroot"
bashrc="./livebuildFiles/.bashrc"
logind="./livebuildFiles/logind.conf"
isolinux="./livebuildFiles/isolinux.cfg"
grub="./livebuildFiles/grub.cfg"

createEnviroment() {

    while true; do
        # Create directory for itadOS
        mkdir ./itadOSLiveBuild
        exitcode=$?

        if [[ "$exitcode" -ne 0 ]]; then
            echo "Failed to create directory for itadOS."
            return 1
        fi

        # create config
        ./config.sh

        # Move itadOS into live-build
        mkdir -p "${config}"/includes.chroot && mv ./"${itadOS}" "${config}"/includes.chroot
        exitcode=$?

        if [[ "$exitcode" -ne 0 ]]; then
            echo "Failed to move itadOS into live-build."
            return 1
        fi

        # Give itadOS execution permission
        chmod +x "${config}"/includes.chroot/itadOSv.0.1.1/main.sh
        exitcode=$?

        if [[ "$exitcode" -ne 0 ]]; then
            echo "Failed to give execution permission to main.sh."
            return 1
        fi

        # Move dependency list to live-build
        mv "${myListChroot}" "${config}"/package-lists/
        exitcode=$?

        if [[ "$exitcode" -ne 0 ]]; then
            echo "Failed to move dependency list to live-build."
            return 1
        fi

        # Move .bashrc to live-build
        mkdir -p "${config}"/root && mv "${bashrc}" "${config}"/root
        exitcode=$?

        if [[ "$exitcode" -ne 0 ]]; then
            echo "Failed to move .bashrc to live-build."
            return 1
        fi

        # Move logind to live-build
        mkdir -p "${config}"/includes.chroot/etc/systemd && mv "${logind}" "${config}"/includes.chroot/etc/systemd
        exitcode=$?

        if [[ "$exitcode" -ne 0 ]]; then
            echo "Failed to move logind to live-build."
            return 1
        fi

        # Move ioslinux to live-build
        mkdir -p "${config}"/includes.binary/isolinux && mv "${isolinux}" "${config}"/includes.binary/isolinux
        exitcode=$?

        if [[ "$exitcode" -ne 0 ]]; then
            echo "Failed to move ioslinux to live-build."
            return 1
        fi

        # Copy COM32 modules to live-build
        cp /usr/lib/syslinux/modules/bios/*.c32 "${config}"/includes.binary/isolinux
        exitcode=$?

        if [[ "$exitcode" -ne 0 ]]; then
            echo "Failed to copy COM32 modules to live-build."
            return 1
        fi

        # Move grub to live-build
        mkdir -p "${config}"/includes.binary/boot/grub && mv "${grub}" "${config}"/includes.binary/boot/grub
        exitcode=$?

        if [[ "$exitcode" -ne 0 ]]; then
            echo "Failed to move grub to live-build."
            return 1
        fi
        
        return 0
        
    done
}
