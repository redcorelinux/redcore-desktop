# Copyright 1999-2016 Gentoo Foundation 
# Distributed under the terms of the GNU General Public License v2  

EAPI=5
inherit eutils qmake-utils

DESCRIPTION="A specialized Qt frontend for FFmpeg and other free media tools"
HOMEPAGE="http://qtlmovie.sourceforge.net/doc/qtlmovie-intro.html"
SRC_URI="https://github.com/${PN}/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND=" 
	dev-qt/qtcore:5
	dev-qt/qtgui:5
	dev-qt/qtmultimedia:5
	dev-qt/qtnetwork:5
	dev-qt/qtwidgets:5
	dev-qt/qtsvg:5
"
RDEPEND="${DEPEND}
	app-cdr/dvd+rw-tools
	media-video/ccextractor
	media-video/dvdauthor
	virtual/cdrtools
	virtual/ffmpeg"

src_configure() {
	eqmake5 PREFIX="${EPREFIX}/usr"  "src/QtlMovie.pro"
}

src_install() {
	# FIXME
	# This project has a very weird source code
	# make does work, but make install doesn't
	# so we must do everything by hand, for now
	dodir usr/bin
	exeinto usr/bin
	doexe QtlMovie/QtlMovie
	dodir usr/share/applications
	insinto usr/share/applications
	doins build/QtlMovie.desktop
	dodir usr/share/qt5/translations
	insinto usr/share/qt5/translations
	for localesrc in QtlMovie libQtl libQts; do
		doins "${localesrc}"/locale/*qm
	done
	dodir usr/share/pixmaps
	insinto usr/share/pixmaps
	newins src/QtlMovie/images/qtlmovie-48.png qtlmovie.png
	sed -i "s/Categories=Qt;AudioVideo;MultiMedia;DiscBurning;System;Filesystem;/Categories=AudioVideo;Video;/g" "${D}"usr/share/applications/QtlMovie.desktop
}
