# Copyright 1999-2016 Gentoo Foundation 
# Distributed under the terms of the GNU General Public License v2  

EAPI=5
inherit eutils qmake-utils

DESCRIPTION="A specialized Qt frontend for FFmpeg and other free media tools"
HOMEPAGE="http://qtlmovie.sourceforge.net/doc/qtlmovie-intro.html"
SRC_URI="https://github.com/redcorelinux/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

RDEPEND=" 
	dev-qt/qtcore:5
	dev-qt/qtgui:5
	dev-qt/qtmultimedia:5
	dev-qt/qtnetwork:5
	dev-qt/qtwidgets:5
	dev-qt/qtsvg:5
"
DEPEND="${RDEPEND}"

src_configure() { 
   eqmake5 PREFIX="${EPREFIX}/usr"  ${PN}.pro 
}

src_install() { 
   make INSTALL_ROOT=${D} install || die 
}
