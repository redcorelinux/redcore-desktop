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

src_install() {
	dodir "/etc/default" || die
	insinto "/etc/default" || die
	doins -r "${S}/"* || die
}

pkg_preinst() {
	if [[ -f ""${ROOT}"etc/default/grub" ]]; then
		cp -avx ""${ROOT}"etc/default/grub" ""${ROOT}"etc/default/grub.backup"
	fi
}

pkg_postinst() {
	elog "Your previous GRUB configuration was saved as /etc/default/grub.backup"
	elog "Please adjust the new configuration to suit you and regenerate the GRUB menu"
	elog "by using : /usr/sbin/grub2-mkconfig -o /boot/grub/grub.cfg"
}
