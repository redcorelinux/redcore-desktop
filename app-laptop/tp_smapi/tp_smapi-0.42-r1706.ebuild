# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit eutils

DESCRIPTION="IBM ThinkPad SMAPI BIOS driver dummy package"
HOMEPAGE="https://github.com/evgeni/${PN}"
SRC_URI="${HOMEPAGE}/releases/download/tp-smapi/${PV}/${P}.tgz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND="~sys-kernel/${PN}-dkms-${PV}"
RDEPEND="${DEPEND}"

src_compile(){
	:
}

src_install() {
	:
}
