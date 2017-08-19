# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

DESCRIPTION="Redcore Linux Dracut configuration files"
HOMEPAGE=""
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

RDEPEND="sys-boot/grub"

S="${FILESDIR}"

src_install() {
	dodir "/etc/dracut.conf.d" || die
	insinto "/etc/dracut.conf.d" || die
	doins -r "${S}/"* || die
}

pkg_preinst() {
	if [[ -f ""${ROOT}"etc/dracut.conf.d/redcore-dracut.conf" ]]; then
		mv ""${ROOT}"etc/dracut.conf.d/redcore-dracut.conf" ""${ROOT}"etc/dracut.conf.d/redcore-dracut.conf.backup"
	fi
}

pkg_postinst() {
	elog "Your previous Dracut configuration was saved as /etc/dracut.conf.d/redcore-dracut.conf.backup"
	elog "Please adjust the new configuration to suit you and regenerate the Dracut initramfs image"
	elog "by using : /usr/bin/dracut -f"
}
