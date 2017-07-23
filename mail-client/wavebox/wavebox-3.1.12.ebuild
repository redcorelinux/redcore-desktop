# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit eutils unpacker

DESCRIPTION="Wavebox lets you bring all your web communication tools together for faster, smarter working. Gmail, Google Inbox, Outlook, Office 365, Slack, Trello & more"
HOMEPAGE="https://wavebox.io"
SRC_URI="https://github.com/${PN}/${PN}app/releases/download/v${PV}/Wavebox_3_1_12_linux_x86_64.deb"

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
	fperms 0755 /opt/${PN}/Wavebox || die
}
