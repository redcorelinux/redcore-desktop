# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
inherit eutils

DESCRIPTION="Broadcom's IEEE 802.11a/b/g/n hybrid Linux device driver source"
HOMEPAGE="http://www.broadcom.com/support/802.11/"
SRC_BASE="http://www.broadcom.com/docs/linux_sta/hybrid-v35"
SRC_URI="amd64? ( ${SRC_BASE}_64-nodebug-pcoem-${PV//\./_}.tar.gz )"

LICENSE="Broadcom"
KEYWORDS="amd64"
SLOT="0"
RESTRICT="mirror"

DEPEND="sys-kernel/dkms"
RDEPEND="${DEPEND}"

PATCHES=(
	"${FILESDIR}"/makefile.patch
	"${FILESDIR}"/eth-to-wlan.patch
	"${FILESDIR}"/gcc.patch
	"${FILESDIR}"/date-time.patch
	"${FILESDIR}"/date-time-error.patch
	"${FILESDIR}"/kernel-4.7-to-kernel-5.10.patch
	"${FILESDIR}"/kernel-5.17.patch
	"${FILESDIR}"/kernel-5.18.patch
	"${FILESDIR}"/kernel-6.0.patch
	"${FILESDIR}"/kernel-6.1.patch
)

S="${WORKDIR}"

src_compile(){
	:
}

src_install() {
	dodir usr/src/${P}
	insinto usr/src/${P}
	doins -r "${S}"/*
	doins "${FILESDIR}"/dkms.conf
	dodir etc/modprobe.d
	insinto etc/modprobe.d
	doins "${FILESDIR}"/"${PN}".conf
}

pkg_postinst() {
	dkms add ${PN}/${PV}
}

pkg_prerm() {
	dkms remove ${PN}/${PV} --all
}
