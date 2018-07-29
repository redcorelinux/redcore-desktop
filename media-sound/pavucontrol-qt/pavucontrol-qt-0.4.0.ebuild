# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit eutils cmake-utils

DESCRIPTION="Qt port of pavucontrol"
HOMEPAGE="http://lxqt.org"
SRC_URI="https://github.com/lxde/${PN}/releases/download/${PV}/${P}.tar.xz"
KEYWORDS="amd64"

LICENSE="GPL"
SLOT="0"
IUSE=""

DEPEND="dev-qt/qtgui:5
	dev-qt/qtwidgets:5
	dev-qt/qtdbus:5
	dev-qt/linguist-tools:5
	dev-libs/glib
	>=lxqt-base/liblxqt-3.2.0
	>=lxqt-base/lxqt-build-tools-0.5.0
	media-sound/pulseaudio"
RDEPEND="${DEPEND}"

src_install() {
	cmake-utils_src_install
	rm -rf ${ED}usr/share/${PN}
}
