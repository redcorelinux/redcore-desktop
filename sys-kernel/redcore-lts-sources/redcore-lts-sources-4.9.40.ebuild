# Copyright 2004-2013 Sabayon Linux
# Copyright 2004-2014 Kogaion, Argent and ArgOS Linux
# Copyright 2016 Redcore Linux
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit versionator

K_ROGKERNEL_NAME="redcore-lts"
K_ROGKERNEL_SELF_TARBALL_NAME="redcore-lts"
K_ROGKERNEL_URI_CONFIG="yes"
K_ONLY_SOURCES="1"
K_ROGKERNEL_FORCE_SUBLEVEL="40"
K_KERNEL_NEW_VERSIONING="1"

inherit redcore-kernel

KEYWORDS="amd64 x86"
DESCRIPTION="Official Redcore Linux Standard kernel sources"
RESTRICT="mirror"
IUSE="sources_standalone"

DEPEND="${DEPEND}
	sources_standalone? ( !=sys-kernel/linux-redcore-${PVR} )
	!sources_standalone? ( =sys-kernel/linux-redcore-${PVR} )"
