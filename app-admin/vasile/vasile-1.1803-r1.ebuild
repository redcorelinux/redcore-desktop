# Copyright 2016-2017 Redcore Linux Project
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils

DESCRIPTION="Versatile Advanced Script for ISO and Latest Enchantments"
HOMEPAGE="https://redcorelinux.org"
SRC_URI="https://github.com/redcorelinux/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64"
IUSE=""

DEPEND="sys-apps/gentoo-functions"
RDEPEND="${DEPEND}
	dev-libs/libisoburn
	dev-vcs/git
	sys-boot/grub:2
	sys-kernel/dkms
	sys-fs/mtools
	sys-fs/squashfs-tools"

src_install() {
	default
	dosym ../../usr/bin/"${PN}".sh usr/bin/"${PN}"
	dodir var/cache/packages
	dodir var/cache/distfiles
}

pkg_postinst() {
	chown portage:portage /var/cache/distfiles
	chmod 775 /var/cache/distfiles
}
