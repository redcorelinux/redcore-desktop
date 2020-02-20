# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
inherit eutils git-r3

DESCRIPTION="Realtek RTL8811CU/RTL8821CU USB Wi-Fi adapter driver for Linux"
HOMEPAGE="https://github.com/brektrou/rtl8821CU"

EGIT_REPO_URI="https://github.com/brektrou/rtl8821CU.git"
EGIT_BRANCH="master"

LICENSE="GPL-2"
KEYWORDS="amd64"
SLOT="0"
RESTRICT="mirror"

DEPEND="sys-kernel/dkms"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${P}"

src_prepare() {
	cp "${FILESDIR}"/dkms.conf "${S}" || die
}

src_compile(){
	:
}

src_install() {
	dodir usr/src/${P}
	insinto usr/src/${P}
	doins -r "${S}"/*
}

pkg_postinst() {
	dkms add ${PN}/${PV}
}

pkg_prerm() {
	dkms remove ${PN}/${PV} --all
}
