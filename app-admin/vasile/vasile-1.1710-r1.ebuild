# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit eutils

DESCRIPTION="Versatile Advanced Script for ISO and Latest Enchantments"
HOMEPAGE="http://redcorelinux.org"
SRC_URI="https://github.com/redcorelinux/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64"
IUSE=""

DEPEND="sys-apps/gentoo-functions"
RDEPEND="${DEPEND}
	dev-libs/libisoburn
	sys-boot/grub:2
	sys-kernel/dkms
	sys-fs/mtools
	sys-fs/squashfs-tools"

src_prepare() {
	default
	eapply "${FILESDIR}/${P}-r1.patch"
}

src_install() {
	default
	dosym /usr/bin/${PN}.sh /usr/bin/${PN}
	dodir /var/cache/packages
	dodir /var/cache/distfiles
}

pkg_postinst() {
	chown portage:portage /var/cache/distfiles
	chmod 775 /var/cache/distfiles
}
