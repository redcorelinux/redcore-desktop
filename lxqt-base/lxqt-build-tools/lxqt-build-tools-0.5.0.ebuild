# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit cmake-utils

DESCRIPTION="Various packaging tools and scripts for LXQt applications"
HOMEPAGE="http://lxqt.org/"

SRC_URI="https://github.com/lxde/${PN}/releases/download/${PV}/${P}.tar.xz"
KEYWORDS="amd64"

LICENSE="GPL-2 LGPL-2.1+"
SLOT="0"

RDEPEND=">=dev-libs/glib-2.50.0
	dev-qt/qtcore:5"
DEPEND="${RDEPEND}
	>=dev-libs/libqtxdg-3.2.0
	dev-qt/linguist-tools:5"

src_configure() {
	local mycmakeargs=( -DPULL_TRANSLATIONS=OFF )
	cmake-utils_src_configure
}
