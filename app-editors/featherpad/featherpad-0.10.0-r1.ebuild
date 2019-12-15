# Copyright 1999-2016 Gentoo Foundation 
# Distributed under the terms of the GNU General Public License v2 

EAPI=6
inherit eutils qmake-utils

DESCRIPTION="Lightweight Qt5 Plain-Text Editor for Linux"
SRC_URI="https://github.com/tsujan/FeatherPad/archive/V${PV}.tar.gz -> ${P}.tar.gz"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

RDEPEND="
	dev-qt/qtcore:5
	dev-qt/qtgui:5
	dev-qt/qtwidgets:5
	dev-qt/qtsvg:5
"
DEPEND="${RDEPEND}"

S="${WORKDIR}"/FeatherPad-"${PV}"

src_configure() {
	eqmake5 PREFIX="${EPREFIX}/usr" fp.pro
}

src_install() {
	emake INSTALL_ROOT=${D} install || die
}
