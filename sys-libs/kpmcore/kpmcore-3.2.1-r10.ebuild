# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit ecm kde.org

if [[ ${KDE_BUILD_TYPE} = release ]]; then
	SRC_URI="mirror://kde/stable/${PN}/${PV}/src/${P}.tar.xz"
	KEYWORDS="amd64 ~arm x86"
fi

DESCRIPTION="Library for managing partitions"
HOMEPAGE="https://www.kde.org/applications/system/kdepartitionmanager"
LICENSE="GPL-3"
SLOT="5/6"
IUSE=""

RDEPEND="
	kde-frameworks/kcoreaddons
	kde-frameworks/ki18n
	kde-frameworks/kservice
	kde-frameworks/kwidgetsaddons
	dev-qt/qtdbus:5
	dev-qt/qtgui:5
	dev-qt/qtwidgets:5
	dev-libs/libatasmart
	>=sys-apps/util-linux-2.30
	>=sys-block/parted-3
"
DEPEND="${RDEPEND}
	virtual/pkgconfig
"
