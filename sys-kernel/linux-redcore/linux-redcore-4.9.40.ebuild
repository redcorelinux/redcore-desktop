# Copyright 2004-2013 Sabayon Linux
# Copyright 2015 Kogaion
# Copyright 2016 Redcore Linux
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit versionator

K_ROGKERNEL_SELF_TARBALL_NAME="redcore"
K_REQUIRED_LINUX_FIRMWARE_VER="20161205"
K_ROGKERNEL_FORCE_SUBLEVEL="40"
K_ROGKERNEL_PATCH_UPSTREAM_TARBALL="0"
K_KERNEL_NEW_VERSIONING="1"

K_MKIMAGE_RAMDISK_ADDRESS="0x81000000"
K_MKIMAGE_RAMDISK_ENTRYPOINT="0x00000000"
K_MKIMAGE_KERNEL_ADDRESS="0x80008000"

inherit redcore-kernel

KEYWORDS="amd64 x86"
DESCRIPTION="Official Redcore Linux Standard kernel image"
RESTRICT="mirror"
