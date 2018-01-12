# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

DESCRIPTION="Redcore Linux GRUB configuration files"
HOMEPAGE=""
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

RDEPEND="sys-boot/grub"

S="${FILESDIR}"

pkg_preinst() {
	# Backup GRUB configuration file
	if [[ -f ""${ROOT}"etc/default/grub" ]]; then
		cp -avx ""${ROOT}"etc/default/grub" ""${ROOT}"etc/default/grub.backup"
	fi
}

src_install() {
	# if we overwrite /etc/default/grub we may break users setup
	# so install the new GRUB configuration file as example only
	dodir "etc/default" || die
	insinto "etc/default" || die
	newins grub grub.example || die
}

pkg_postinst() {
	# Restore GRUB configuration file
	if [[ -f ""${ROOT}"etc/default/grub.backup" ]]; then
		cp -avx ""${ROOT}"etc/default/grub.backup" ""${ROOT}"etc/default/grub"
	fi
}
