# Copyright 1999-2016 Gentoo Foundation 
# Distributed under the terms of the GNU General Public License v2 

EAPI=5
inherit eutils qmake-utils

DESCRIPTION="Qt frontend for youtube-dl"
SRC_URI="https://github.com/rrooij/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

RDEPEND="
	dev-qt/qtcore:5
	dev-qt/qtgui:5  
	dev-qt/qtwidgets:5
	net-misc/youtube-dl  
"
DEPEND="${RDEPEND}"

src_configure() { 
	eqmake5 PREFIX="${EPREFIX}/usr"  ${PN}.pro 
}

src_install() { 
	make INSTALL_ROOT=${D} install || die 
}
