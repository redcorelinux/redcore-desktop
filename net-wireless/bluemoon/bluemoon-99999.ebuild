# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
inherit qmake-utils git-r3

DESCRIPTION="Bluetooth Manager for qt5"
HOMEPAGE="https://github.com/sklins/BlueMoon.git"
EGIT_REPO_URI="https://github.com/sklins/BlueMoon.git"
KEYWORDS="~amd64"
LICENSE="GPL-2 LGPL-2.1+"
SLOT="0"

DEPEND="
	dev-qt/qtcore:5
	dev-qt/qtgui:5
	dev-qt/qtbluetooth:5
"
RDEPEND="${DEPEND}"

PATCHES=( "${FILESDIR}"/icon.patch )

S=${S}/BlueMoon
src_configure() {
	mv ../icons/scalable_bluemoon.svg blue_moon.svg
	eqmake5
}

src_install() {
	exeinto /usr/bin
	doexe blue_moon

	insinto /usr/share/pixmaps
	doins blue_moon.svg

}
