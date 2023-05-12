# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit eutils

NV_URI="http://us.download.nvidia.com/XFree86/"
AMD64_NV_PACKAGE="NVIDIA-Linux-x86_64-${PV}"

DESCRIPTION="NVIDIA driver sources for linux"
HOMEPAGE="http://www.nvidia.com/"
SRC_URI="amd64? ( ${NV_URI}Linux-x86_64/${PV}/${AMD64_NV_PACKAGE}.run )"

LICENSE="GPL-2 NVIDIA-r2"
SLOT="525"
KEYWORDS="amd64"
IUSE="kernel-open"

DEPEND="sys-kernel/dkms"
RDEPEND="${DEPEND}
	!!sys-kernel/nvidia-drivers-dkms:390
	!!sys-kernel/nvidia-drivers-dkms:470
	!!sys-kernel/nvidia-drivers-dkms:515"

PATCHES=(
	"${FILESDIR}"/dkms525.patch
)

S="${WORKDIR}/${AMD64_NV_PACKAGE}"

src_unpack() {
	sh ${DISTDIR}/${AMD64_NV_PACKAGE}.run --extract-only
}

src_install() {
	dodir usr/src/${P}
	insinto usr/src/${P}
	if use kernel-open; then
		doins -r "${S}"/kernel-open/*
	else
		doins -r "${S}"/kernel/*
	fi
}

pkg_postinst() {
	dkms add ${PN}/${PV}
}

pkg_prerm() {
	dkms remove ${PN}/${PV} --all
}
