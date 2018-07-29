# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils

SRC_URI="https://github.com/lxde/${PN}/releases/download/${PV}/${P}.tar.xz"
KEYWORDS="~amd64"

DESCRIPTION="Fast lightweight tabbed filemanager (Qt port)"
HOMEPAGE="https://wiki.lxde.org/en/PCManFM"

LICENSE="GPL-2+"
SLOT="0"
IUSE="samba"

CDEPEND=">=dev-libs/glib-2.50.0:2
	dev-qt/qtcore:5
	dev-qt/qtdbus:5
	dev-qt/qtgui:5
	dev-qt/qtwidgets:5
	dev-qt/qtx11extras:5
	>=x11-libs/libfm-1.3.0:=
	x11-libs/libfm-qt:=
	x11-libs/libxcb:="
RDEPEND="${CDEPEND}
	samba? ( net-fs/samba
		x11-misc/pcmanfm-qt-share
	)
	x11-misc/xdg-utils
	virtual/eject
	virtual/freedesktop-icon-theme"
DEPEND="${CDEPEND}
	dev-qt/linguist-tools:5
	>=dev-util/intltool-0.40
	sys-devel/gettext
	virtual/pkgconfig"

src_configure() {
	local mycmakeargs=(
		-DPULL_TRANSLATIONS=NO
	)

	cmake-utils_src_configure
}
