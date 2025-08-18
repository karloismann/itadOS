#!/bin/bash

script_dir=$(realpath "$(dirname "$0")")
itadOS="${script_dir}/../itadOSv.0.1.1"
itadOSLiveBuild="${script_dir}/itadOSLiveBuild"

myListChroot="${script_dir}/livebuildFiles/confFiles/my.list.chroot"
bashrc="${script_dir}/livebuildFiles/confFiles/.bashrc"
logind="${script_dir}/livebuildFiles/confFiles/logind.conf"
isolinux="${script_dir}/livebuildFiles/confFiles/isolinux.cfg"
grub="${script_dir}/livebuildFiles/confFiles/grub.cfg"

createEnviroment() {

    cd "$script_dir"

    while true; do
        # Create directory for itadOS
        mkdir ./itadOSLiveBuild
        exitcode=$?

        if [[ "$exitcode" -ne 0 ]]; then
            echo "Failed to create directory for itadOS."
            return 1
        fi

        cd "${script_dir}"/itadOSLiveBuild

        # create config
        source "${script_dir}"/livebuildFiles/scripts/config.sh
        createConfig "itadOSLiveBuild" &
        configPID=$!
        wait "$configPID"

        config="${script_dir}/itadOSLiveBuild/config"

        # Move itadOS into live-build
        mkdir -p "${config}"/includes.chroot && cp -r "${itadOS}" "${config}"/includes.chroot
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
        mkdir -p "${config}"/package-lists && cp "${myListChroot}" "${config}"/package-lists/
        exitcode=$?

        if [[ "$exitcode" -ne 0 ]]; then
            echo "Failed to move dependency list to live-build."
            return 1
        fi

        # Move .bashrc to live-build
        mkdir -p "${config}"/includes.chroot/root && cp "${bashrc}" "${config}"/includes.chroot/root/
        exitcode=$?

        if [[ "$exitcode" -ne 0 ]]; then
            echo "Failed to move .bashrc to live-build."
            return 1
        fi

        # Move logind to live-build
        mkdir -p "${config}"/includes.chroot/etc/systemd && cp "${logind}" "${config}"/includes.chroot/etc/systemd
        exitcode=$?

        if [[ "$exitcode" -ne 0 ]]; then
            echo "Failed to move logind to live-build."
            return 1
        fi

        # Move ioslinux to live-build
        mkdir -p "${config}"/includes.binary/isolinux && cp "${isolinux}" "${config}"/includes.binary/isolinux
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
        mkdir -p "${config}"/includes.binary/boot/grub && cp "${grub}" "${config}"/includes.binary/boot/grub
        exitcode=$?

        if [[ "$exitcode" -ne 0 ]]; then
            echo "Failed to move grub to live-build."
            return 1
        fi
        
        return 0
        
    done
}
