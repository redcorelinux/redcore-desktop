# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
inherit eutils

DESCRIPTION="Realtek RTL8821CU USB Wi-Fi adapter driver for Linux "
HOMEPAGE="https://github.com/brektrou/rtl8821CU"
SRC_URI=""

LICENSE="GPL-2"
KEYWORDS="amd64"

RESTRICT="mirror"
SLOT="0"

DEPEND="~sys-kernel/${PN}-dkms-${PV}"
RDEPEND="${DEPEND}"

S=${WORKDIR}

src_install() {
	:
}
