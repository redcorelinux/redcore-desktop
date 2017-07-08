# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit eutils

DESCRIPTION="Mediatek/Ralink rt3290 wifi driver sources for Linux 4.x"
HOMEPAGE="https://www.mediatek.com/products/connectivity-and-networking/broadband-wifi"
SRC_URI="http://mirror.math.princeton.edu/pub/redcorelinux/distfiles/${CATEGORY}/${P}.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND="sys-kernel/dkms"
RDEPEND="${DEPEND}"

S=${WORKDIR}/${P}

src_compile() {
	:
}

src_install() {
	dodir /usr/src/${P}
	insinto /usr/src/${P}
	doins -r "${S}"/*
}

pkg_postinst() {
	dkms add ${PN}/${PV}
}

pkg_prerm() {
	dkms remove ${PN}/${PV} --all
}

