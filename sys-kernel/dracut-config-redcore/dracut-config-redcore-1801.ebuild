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

pkg_preinst() {
	# Backup Dracut configuration file
	if [[ -f ""${ROOT}"etc/dracut.conf.d/redcore-dracut.conf" ]]; then
		cp -avx ""${ROOT}"etc/dracut.conf.d/redcore-dracut.conf" ""${ROOT}"etc/dracut.conf.d/redcore-dracut.conf.backup"
	fi
}

src_install() {
	# if we overwrite /etc/dracut.conf.d/redcore-dracut.conf we may break users setup
	# so install the new Dracut configuration file as example only
	dodir "etc/dracut.conf.d" || die
	insinto "etc/dracut.conf.d" || die
	newins redcore-dracut.conf redcore-dracut.conf.example || die

pkg_postinst() {
	# Restore Dracut configuration file
	if [[ -f ""${ROOT}"etc/dracut.conf.d/redcore-dracut.conf.backup" ]]; then
        cp -avx ""${ROOT}"etc/dracut.conf.d/redcore-dracut.conf.backup" ""${ROOT}"etc/dracut.conf.d/redcore-dracut.conf"
    fi
}
