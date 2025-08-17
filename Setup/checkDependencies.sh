#!/bin/bash

# List of dependencies
packages=("whiptail" "nvme-cli" "lshw" "coreutils" "util-linux" "mmc-utils" "smartmontools" "pciutils" "fop" "xsltproc" "live-build" "isolinux")


# Checks if package is installed 
# @param $1: package to check 
# @returns 0 if package is installed
# @returns 1 if package is NOT installed
isInstalled() {

  package="$1"

  check="$(dpkg -l "$package" 2>/dev/null | awk -v pkg="$package" '$0 ~ pkg{print $1}' | xargs)"
  #echo "$check"

  if [[ "$check" == "ii" ]]; then

    return 0

  else

    return 1

  fi

}

# Checks is dependencies are installed.
# If not, prompts user to install missing packages.
checkDependencies() {
  for pkg in ${packages[@]}; do

    if isInstalled "$pkg"; then
      echo "${pkg} installed"
    else
	  
	  # Ask user to install whiptail without use of TUI (whiptail).
      if [[ "$pkg" == "whiptail" ]]; then
      
        while true; do

			echo "${pkg} not installed. Do you wish to install? [Y/N]"
			read choice
			choice=${choice,,}

			if [[ "$choice" != "y" && "$choice" != "n" ]]; then
			 echo "Please enter Y or N."
			else
			 break
			fi

		  done

		  case "$choice" in
			y)
			  apt install "$pkg" -y
			;;
			n)
			  echo "${pkg} installation skipped. ItadOS will not function as intended."
			;;
		  esac
	  
	  # Ask user to install missing packages. 
      else        

		  whiptail --yesno "${pkg} not installed. Do you wish to install?" 0 0
	      exit=$?

		  case "$exit" in
			0)
			  apt install "$pkg" -y
			;;
			1)
			  whiptail --msgbox "${pkg} installation skipped. ItadOS will not function as intended." 0 0
			;;
		  esac
		  
		fi

    fi

  done
}

checkDependencies
