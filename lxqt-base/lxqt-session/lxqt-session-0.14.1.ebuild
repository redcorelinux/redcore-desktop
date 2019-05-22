# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit cmake-utils eutils

DESCRIPTION="LXQT session manager"
HOMEPAGE="http://lxqt.org/"

SRC_URI="https://github.com/lxde/${PN}/releases/download/${PV}/${P}.tar.xz"
KEYWORDS="amd64"
IUSE="+gtk"

LICENSE="GPL-2 LGPL-2.1+"
SLOT="0"

CDEPEND="
	>=dev-libs/libqtxdg-3.2.0
	dev-qt/qtcore:5
	dev-qt/qtdbus:5
	dev-qt/qtgui:5
	dev-qt/qtwidgets:5
	dev-qt/qtx11extras:5
	dev-qt/qtxml:5
	kde-frameworks/kwindowsystem:5[X]
	~lxqt-base/liblxqt-${PV}
	x11-libs/libX11
	x11-misc/xdg-user-dirs
	gtk? ( ~lxqt-base/lxqt-config-${PV}[gtk] )"
DEPEND="${CDEPEND}
	dev-qt/linguist-tools:5
	dev-util/intltool
	!!lxqt-base/lxqt-common
	sys-devel/gettext
	virtual/pkgconfig"
RDEPEND="${CDEPEND}
	~lxqt-base/lxqt-themes-${PV}"

src_prepare () {
	if use gtk; then
		# Redcore patch, to override default platform plugin to qgtk2
		epatch ${FILESDIR}/${PN}-override-default-platformplugin.patch
		cmake-utils_src_prepare
	else
		cmake-utils_src_prepare
	fi
}

src_configure() {
	local mycmakeargs=( -DPULL_TRANSLATIONS=OFF )
	cmake-utils_src_configure
}

src_install(){
	cmake-utils_src_install
	dodir "/etc/xdg/lxqt"
	insinto "/etc/xdg/lxqt"
	doins "${FILESDIR}/session.conf"
	doman lxqt-config-session/man/*.1 lxqt-session/man/*.1
	dodir "/etc/X11/Sessions"
	dosym  "/usr/bin/startlxqt" "/etc/X11/Sessions/lxqt"
}
