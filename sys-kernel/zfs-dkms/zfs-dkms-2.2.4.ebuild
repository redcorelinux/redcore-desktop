# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit eutils

MY_PN="zfs"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="ZFS sources for linux"
HOMEPAGE="http://zfsonlinux.org/"
SRC_URI="https://github.com/zfsonlinux/zfs/releases/download/zfs-${PV}/${MY_P}.tar.gz"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="amd64"
IUSE=""
DEPEND="sys-kernel/dkms"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_P}"

src_configure() {
	:
}

src_compile() {
	:
}

src_install() {
	dodir usr/src/"${P}"
	cp -ax "${FILESDIR}"/dkms.conf "${S}" || die
	cp -ax "${S}"/* "${D}"usr/src/"${P}" || die
}

pkg_postinst() {
	dkms add ${PN}/${PV}
}

pkg_prerm() {
	dkms remove ${PN}/${PV} --all
}
