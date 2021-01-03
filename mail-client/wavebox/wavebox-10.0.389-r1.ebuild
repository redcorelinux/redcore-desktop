# Copyright 2016-2019 Redcore Linux Project
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit eutils

MY_PN="Wavebox"

DESCRIPTION="The next generation of web-desktop communication"
HOMEPAGE="https://wavebox.io"
SRC_URI="https://download.wavebox.app/stable/linux/tar/${MY_PN}_${PV}-2.tar.gz"

LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="dev-libs/nss
	gnome-base/gconf
	media-libs/alsa-lib
	sys-apps/lsb-release
	x11-libs/gtk+:2
	x11-libs/libXtst
	x11-libs/libnotify"
RDEPEND="${DEPEND}"

RESTRICT="mirror strip"

S="${WORKDIR}/${PN}_${PV}-2"

src_install() {
	dodir /opt/${PN}
	insinto /opt/${PN}
	doins -r ${S}/*
	fperms 0755 /opt/${PN}/${PN}

	dodir /usr/share/applications
	insinto /usr/share/applications
	doins ${FILESDIR}/${PN}.desktop

	fperms 4711 /opt/${PN}/chrome-sandbox
}
