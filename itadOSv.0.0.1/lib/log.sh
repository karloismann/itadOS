#!/bin/bash


log() {
    local message="$1"
    local timestamp="$(date '+%Y-%m-%d %H:%M:%S')"

    echo "${timestamp}: ${message}" >> "$LOG_FILE"
}