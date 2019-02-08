# Copyright 2016-2019 Redcore Linux Project
# Distributed under the terms of the GNU General Public License v2 

EAPI=5

inherit eutils qmake-utils git-r3

DESCRIPTION="A good looking terminal emulator which mimics the old cathode display"
HOMEPAGE="https://github.com/Swordfish90/"
LICENSE="GPL-2"

EGIT_REPO_URI="${HOMEPAGE}${PN}.git"

SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="
	dev-qt/qtcore:5
	dev-qt/qtdeclarative:5[localstorage]
	dev-qt/qtgraphicaleffects:5
	dev-qt/qtgui:5
	dev-qt/qtquickcontrols:5[widgets]
	dev-qt/qtwidgets:5
	dev-qt/qtsvg:5
"
DEPEND="${RDEPEND}"

src_unpack() {
	git-r3_fetch ${EGIT_REPO_URI} refs/tags/${PV} || die
	git-r3_checkout || die
}

src_configure() {
	eqmake5 PREFIX="${EPREFIX}/usr"  ${PN}.pro || die
}

src_install() {
	make INSTALL_ROOT=${D} install || die
}
