# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit eutils unpacker autotools

DESCRIPTION="A simple & beautiful app for Facebook Messenger."
HOMEPAGE="https://messengerfordesktop.com/"
SRC_URI="https://github.com/aluxian/Messenger-for-Desktop/releases/download/v${PV}/${P}-linux-amd64.deb"

SLOT='0'
KEYWORDS="amd64"

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
	fperms 0755 /opt/${PN}/${PN} || die
}
