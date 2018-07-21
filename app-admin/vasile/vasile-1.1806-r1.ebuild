# Copyright 2016-2018 Redcore Linux Project
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils

DESCRIPTION="Versatile Advanced Script for ISO and Latest Enchantments"
HOMEPAGE="https://redcorelinux.org"
SRC_URI="https://gitlab.com/redcore/${PN}/-/archive/v${PV}/${PN}-v${PV}.tar.gz -> ${P}.tar.gz"
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

PATCHES=( ${FILESDIR}/nuke-gitlab-switch-to-cgit.patch )

S=${WORKDIR}/${PN}-v${PV}

src_install() {
	default
	dosym ../../usr/bin/"${PN}".sh usr/bin/"${PN}"
	dodir var/cache/packages
	dodir var/cache/distfiles
}

_cgit_migration_warning() {
	einfo ""
	einfo "We nuked Gitlab due to service unreliability, so from now on vasile will use our own git instance"
	einfo ""
	einfo "You must reset your current mode using:"
	einfo ""
	einfo "vasile --binmode (for binmode)"
	einfo "vasile --mixedmode (for mixedmode)"
	einfo "vasile --srcmode (for srcmode)"
	einfo ""
	einfo "Before reseting, you may want to backup any of your local changes (mixedmode && srcmode users only)"
	einfo ""
}

pkg_postinst() {
	chown portage:portage /var/cache/distfiles
	chmod 775 /var/cache/distfiles
	_cgit_migration_warning
}
