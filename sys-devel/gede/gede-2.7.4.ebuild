# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit eutils qmake-utils

DESCRIPTION="A graphical frontend (GUI) to GDB written in C++ and using the Qt4 (or Qt5) toolkit"
HOMEPAGE="http://gede.acidron.com/"
SRC_URI="http://gede.acidron.com/uploads/source/${P}.tar.xz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="
	dev-qt/qtcore:5
	dev-qt/qtgui:5
	dev-qt/qtwidgets:5"
RDEPEND="${DEPEND}
	sys-devel/gdb"

S="${WORKDIR}"/"${P}"/src

src_configure() {
	eqmake5 PREFIX="${EPREFIX}/usr" gd.pro
}

src_install() {
	# install the binary
	dodir usr/bin
	exeinto usr/bin
	doexe ${PN}
	# TODO
	# install icon
	# install desktop file
}
