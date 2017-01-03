# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit eutils

DESCRIPTION="Tianocore UEFI firmware for qemu"
HOMEPAGE="http://sourceforge.net/apps/mediawiki/tianocore/index.php?title=EDK2"
SRC_URI="http://mirror.pseudoform.org/extra/os/x86_64/${P}-1-any.pkg.tar.xz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"
S="${WORKDIR}"/usr/share/${PN}

src_install() {
	dodir /usr/share/${PN}
	insinto /usr/share/${PN}
	doins -r "${S}"/*
}
