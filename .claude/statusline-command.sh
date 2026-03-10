#!/bin/bash

# Converted from PS1: ${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$

# Check for debian_chroot
chroot_prefix=""
if [ -n "$debian_chroot" ]; then
    chroot_prefix="($debian_chroot)"
elif [ -r /etc/debian_chroot ]; then
    chroot_prefix="($(cat /etc/debian_chroot))"
fi

# Get user, hostname, and current directory
user=$(whoami)
hostname=$(hostname -s)
cwd=$(pwd)

# Build the status line with colors
# Note: Using printf for ANSI colors
# \033[01;32m = bold green
# \033[01;34m = bold blue
# \033[00m = reset

printf "%s\033[01;32m%s@%s\033[00m:\033[01;34m%s\033[00m" "$chroot_prefix" "$user" "$hostname" "$cwd"
