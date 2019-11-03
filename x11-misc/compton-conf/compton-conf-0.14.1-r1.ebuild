# Copyright 2016-2017 Redcore Linux Project
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit kde5

DESCRIPTION="GUI configuration tool for compton X composite manager"
HOMEPAGE="https://github.com/lxde/compton-conf"
SRC_URI="https://github.com/lxde/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND="
	$(add_qt_dep qtdbus)
	$(add_qt_dep qtgui)
	$(add_qt_dep linguist-tools)
	$(add_qt_dep qtwidgets)
	>=lxqt-base/lxqt-build-tools-0.6.0"
RDEPEND="${DEPEND}"

src_install() {
	cmake-utils_src_install
	rm -rf "${D}"usr/share/"${PN}"
}
