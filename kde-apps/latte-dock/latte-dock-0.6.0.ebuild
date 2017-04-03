# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit kde5

MY_PN=Latte-Dock
DESCRIPTION="A dock based on plasma frameworks"
HOMEPAGE="https://psifidotos.blogspot.co.uk/2017/04/latte-dock-v06-fresh-air.html"

SRC_URI="https://github.com/psifidotos/${MY_PN}/archive/v${PV}.tar.gz"

LICENSE="GPL"
KEYWORDS="amd64 x86"
IUSE="+X"

S=${WORKDIR}/${MY_PN}-${PV}

DEPEND="
	$(add_frameworks_dep kactivities)
	$(add_frameworks_dep kcoreaddons)
	$(add_frameworks_dep kdbusaddons)
	$(add_frameworks_dep kdeclarative)
	$(add_frameworks_dep kwayland)
	$(add_frameworks_dep kpackage)
	$(add_frameworks_dep kxmlgui)
	$(add_frameworks_dep kiconthemes)
	$(add_frameworks_dep ki18n)
	$(add_frameworks_dep knotifications)
	$(add_frameworks_dep karchive)
	$(add_frameworks_dep plasma)
	$(add_qt_dep qtdbus)
	$(add_qt_dep qtgui)
	X? (
		$(add_frameworks_dep kwindowsystem)
		$(add_qt_dep qtx11extras)
		x11-libs/libxcb
	)
"
RDEPEND="${DEPEND}
"

src_configure() {
	export BUILD_DIR=${S}/build
	local mycmakeargs=(
		-DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Gentoo
	)

	kde5_src_configure
}
