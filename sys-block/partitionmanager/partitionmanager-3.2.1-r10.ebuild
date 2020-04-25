# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

KDE_HANDBOOK="forceoptional"
inherit ecm kde.org

DESCRIPTION="KDE utility for management of partitions and file systems"
HOMEPAGE="https://www.kde.org/applications/system/kdepartitionmanager"
[[ ${KDE_BUILD_TYPE} == release ]] && SRC_URI="mirror://kde/stable/${PN}/${PV}/src/${P}.tar.xz"

LICENSE="GPL-3"
KEYWORDS="amd64 ~arm x86"
IUSE=""

DEPEND="
	kde-frameworks/kconfig
	kde-frameworks/kconfigwidgets
	kde-frameworks/kcoreaddons
	kde-frameworks/kcrash
	kde-frameworks/ki18n
	kde-frameworks/kiconthemes
	kde-frameworks/kio
	kde-frameworks/kjobwidgets
	kde-frameworks/kservice
	kde-frameworks/kwidgetaddons
	kde-frameworks/kxmlgui
	dev-qt/qtgui:5
	dev-qt/qtwidgets:5
	sys-apps/util-linux
	>=sys-libs/kpmcore-3.2.0:5=
"
RDEPEND="${DEPEND}
	kde-plasma/kde-cli-tools
	kde-plasma/kdesu
"
