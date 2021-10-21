# Copyright 2016-2021 Redcore Linux Project
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit eutils unpacker

DESCRIPTION="A beautiful fast and maintained fork of Nylas Mail"
HOMEPAGE="https://getmailspring.com/"
SRC_URI="https://github.com/Foundry376/Mailspring/releases/download/${PV}/${P}-amd64.deb"

LICENSE="GPL3"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="
	app-crypt/libsecret
	app-text/htmltidy
	dev-cpp/ctemplate
	dev-libs/nss
	dev-libs/openssl-compat:1.0.0
	media-libs/alsa-lib
	net-dns/c-ares
	sys-libs/db:5.3
	x11-libs/gtk+:3
	x11-libs/libxkbfile
	x11-libs/libXtst
	x11-libs/libnotify"
RDEPEND="${DEPEND}"

RESTRICT="mirror strip"

S="${WORKDIR}"

src_unpack() {
	unpack_deb ${A}
}

src_install() {
	rm -rf ${S}/usr/share/doc || die
	cp -R ${S}/* "${D}" || die
}
