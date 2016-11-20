# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit eutils git-r3

DESCRIPTION="Versatile Advanced Script for ISO and Latest Enchantments"
HOMEPAGE="http://redcorelinux.org"

EGIT_BRANCH="master"
EGIT_REPO_URI="https://gitlab.com/redcore/vasile.git"
EGIT_COMMIT="e761102fc50e6961174f09c68df618d76bd6c747"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64"
IUSE=""

DEPEND="
	sys-apps/gentoo-functions
	sys-fs/squashfs-tools
	sys-boot/grub:2
	dev-libs/libisoburn
	sys-fs/mtools"
RDEPEND="${DEPEND}"

src_install() {
	dodir /usr/bin
	exeinto /usr/bin
	doexe ${S}/${PN}
	dodir /usr/$(get_libdir)/${PN}
	insinto /usr/$(get_libdir)/${PN}
	doins ${S}/libvasile
}

