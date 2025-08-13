#!/bin/bash


# Format
###################################################################

# itadOS information
export ERASURE_NAME_CONF=""
export ITADOS_VERSION_CONF="itadOS v.0.0.1"
# "lib/files/stylesheet/logo/itadOS.png" for itadOS logo
# "lib/files/stylesheet/logo/placeholder.png" for placeholder logo
export ERASURE_LOGO_CONF="lib/files/stylesheet/logo/itadOS.png"


# System specifications
# full: lshw -short dump
# min: main specifications, easy to read
# Options: full, min
export SYSTEM_SPEC_CONF="min"


# Service Information
###################################################################
export TECHNICIAN_CONF=""
export PROVIDER_CONF=""
export LOCATION_CONF=""
export CUSTOMER_CONF=""
export JOBNR_CONF=""


# Erasure specification
####################################################################

# Purge: Most secure erasure methods; Not supported by all disks
# Clear: Less secure erasure methods; Supported by majority of disks
# Auto: If purge fails, falls back to clear.
# Skip: skips erasure
# options: purge, clear, auto, skip
export ERASURE_SPEC_CONF="skip"

# Full: Scans entire disks for zero pattern [ CURRENTLY ONLY PURGE AND CLEAR SPEC VERIFICATION ]
# Partial: Scans first and last 10% of disk for zero pattern
# Skip: Skips verification.
# options: full, partial, sampling, skip 
export VERIFICATION_CONF="sampling"

# Other
####################################################################

# Allows user to manually enter Service information, erasure specifications and other settings upon boot
# options: on,off
export MANUAL_USER_CONF="on"

# Checks if disk has zero pattern after erasure, if not then fill with zero.
# If 'off' then checks for zero pattern and adds a message if non zero spotted.
# options: on, off
export CHECK_ZERO_PATTERN_AND_OVERWRITE_CONF="on"

# Set Asset tag manually or automatically set asset tag as serial number
# options: asset, serial
export ASSET_CONF="asset"


# If 'on' Does not show boot disk as erasable
# options: on, off
export FILTER_BOOT_DISK_CONF="off"


# SMART health check variants
# short: quick check, takes up to 2 minutes
# long: more comprehensive test, can take hours
# skip: skips health check
# options: short, long, skip
export SMART_TEST_CONF="short"

# Suspends computer before attemting erasure attempts.
# This setting does not affect automatic suspension required for some SATA operations.
# options: on, off 
export SUSPEND_CONF="off"

# Automatically erases all attached disks [ excluding boot disk if filter on ]
# options: on, off 
export AUTO_ERASURE_CONF="off"

