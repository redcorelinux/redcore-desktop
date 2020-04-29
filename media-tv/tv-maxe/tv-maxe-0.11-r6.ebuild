# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=6

PYTHON_COMPAT=( python2_7 )

inherit eutils python-r1

DESCRIPTION="Program to view free channels"
HOMEPAGE="http://code.google.com/p/tv-maxe"
SRC_URI="https://launchpad.net/~venerix/+archive/ubuntu/pkg/+files/${PN}_${PV}-0ubuntu2~trusty.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+sqlite +vlc"

DEPEND="dev-lang/python[sqlite]"
RDEPEND="${DEPEND}
	vlc? ( media-video/vlc )
	dev-python/pillow[${PYTHON_USEDEP}]
	dev-python/pygtk[${PYTHON_USEDEP}]
	media-tv/sopcast
	media-video/rtmpdump
	virtual/ffmpeg"

S="${WORKDIR}/${PN}-${PV}"

src_prepare() {
	default
	eapply ${FILESDIR}/${PN}_disable_locale.patch
	sed -i "s/python/python2/g" ${PN}/${PN}
}

src_install() {
	dodir usr/bin
	exeinto usr/bin
	doexe ${PN}/${PN}

	dodir usr/share/${PN}
	insinto usr/share/${PN}
	doins -r ${PN}/*

	newicon ${PN}/tvmaxe_mini.png tv-maxe.png
	make_desktop_entry tv-maxe TV-maxe \
		"tv-maxe" \
		AudioVideo
}
