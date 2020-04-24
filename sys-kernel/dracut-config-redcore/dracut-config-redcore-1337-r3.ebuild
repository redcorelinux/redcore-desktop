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

RDEPEND="sys-kernel/dracut"

S="${FILESDIR}"

src_install() {
	dodir "etc/dracut.conf.d" || die
	insinto "etc/dracut.conf.d" || die
	doins redcore-dracut.conf || die
	newins redcore-dracut.conf redcore-dracut.conf.example || die
}

pkg_preinst() {
	if [[ -f ""${ROOT}"etc/dracut.conf.d/redcore-dracut.conf" ]]; then
		rm -rf ""${ROOT}"etc/dracut.conf.d/redcore-dracut.conf"
	fi
}
