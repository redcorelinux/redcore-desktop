# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python{3_4,3_5} )

inherit eutils python-r1

DESCRIPTION="Qt terminal emulator widget"
HOMEPAGE="https://github.com/lxde/qtermwidget"
SRC_URI="https://github.com/lxde/${PN}/releases/download/${PV}/${P}.tar.xz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="amd64 ~arm x86"
IUSE=""

DEPEND="
	dev-python/PyQt5[${PYTHON_USEDEP}]
	dev-python/sip[${PYTHON_USEDEP}]
	dev-qt/qtcore:5
	dev-qt/qtgui:5
	dev-qt/qtwidgets:5
	~x11-libs/qtermwidget-${PV}
"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${PN}-${PV}/pyqt"

src_compile () {
	python_foreach_impl python config.py
	emake || die
}

src_install () {
	default
}
