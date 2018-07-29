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

PATCHES=( ${FILESDIR}/nuke-gitlab-switch-to-cgit.patch
	${FILESDIR}/switch-to-pagure.patch )

S=${WORKDIR}/${PN}-v${PV}

src_install() {
	default
	dosym ../../usr/bin/"${PN}".sh usr/bin/"${PN}"
	dodir var/cache/packages
	dodir var/cache/distfiles
}

_migration_warning() {
	elog ""
	elog "We nuked Gitlab due to service unreliability, vasile will use pagure.io from now on"
	elog ""
	elog "You must reset your current mode using:"
	elog ""
	elog "vasile --binmode (for binmode)"
	elog "vasile --mixedmode (for mixedmode)"
	elog "vasile --srcmode (for srcmode)"
	elog ""
	elog "Before reseting, you may want to backup any of your local changes (mixedmode && srcmode users only)"
	elog ""
}

pkg_postinst() {
	chown portage:portage /var/cache/distfiles
	chmod 775 /var/cache/distfiles
	_migration_warning
}
