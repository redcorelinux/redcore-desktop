# Copyright 2016-2019 Redcore Linux Project
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit eutils

MY_PN="Wavebox"
MY_PV="4_11_4"
MY_P="${MY_PN}_${MY_PV}"

DESCRIPTION="The next generation of web-desktop communication"
HOMEPAGE="https://wavebox.io"
SRC_URI="https://github.com/${PN}/waveboxapp/releases/download/v${PV}/${MY_P}_linux_x86_64.tar.gz"

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

S="${WORKDIR}/${MY_PN}-linux-x64"

src_install() {
	dodir /opt/${PN}
	insinto /opt/${PN}
	doins -r ${S}/*
	fperms 0755 /opt/${PN}/${MY_PN}

	dodir /usr/share/applications
	insinto /usr/share/applications
	doins ${FILESDIR}/${PN}.desktop
}
