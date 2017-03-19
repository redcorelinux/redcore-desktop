# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit eutils unpacker

DESCRIPTION="The missing desktop client for Gmail & Google Inbox"
HOMEPAGE="https://github.com/Thomas101/wmail"
SRC_URI="https://github.com/Thomas101/wmail/releases/download/v${PV}/WMail_2_3_0_linux_x86_64.deb"

LICENSE="GPL2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND="dev-libs/nss
	gnome-base/gconf
	media-libs/alsa-lib
	sys-apps/lsb-release
	x11-libs/gtk+:2
	x11-libs/libXtst
	x11-libs/libnotify"
RDEPEND="${DEPEND}"

RESTRICT="mirror"

S="${WORKDIR}"

src_unpack() {
	unpack_deb ${A}
}

src_install() {
	mv * "${D}" || die
	fperms 0755 /opt/${PN}-desktop/WMail || die
}
