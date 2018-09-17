# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit gnome2 cmake-utils qmake-utils

DESCRIPTION="Easy automated syncing with MEGA Cloud Drive"
HOMEPAGE="https://github.com/meganz/MEGAsync"
SRC_URI="https://github.com/meganz/MEGAsync/archive/v${PV}_Linux.tar.gz -> ${P}.tar.gz"

SLOT="0"
IUSE="dolphin +mediainfo nautilus +qt5 thunar"
REQUIRED_USE="dolphin? ( qt5 )"

KEYWORDS="~amd64"

RDEPEND="
	net-misc/meganz-sdk[libuv,mediainfo?,qt,sodium(+),sqlite]
	qt5? (
		dev-qt/qtsvg:5
		dev-qt/qtdbus:5
	)
	!qt5? (
		dev-qt/qtsvg:4
		dev-qt/qtdbus:4
	)
	dolphin? ( kde-apps/dolphin )
	nautilus? ( >=gnome-base/nautilus-3 )
	thunar? ( xfce-base/thunar )
	mediainfo? ( media-libs/libmediainfo )"
DEPEND="${RDEPEND}
	qt5? ( dev-qt/linguist-tools:5 )"

S="${WORKDIR}"/MEGAsync-"${PV}"_Linux
CMAKE_USE_DIR="${S}"/src/MEGAShellExtDolphin
CMAKE_IN_SOURCE_BUILD=y

src_prepare() {
	local PATCHES=(
		"${FILESDIR}"/${PN}-qmake.diff
	)
	cp -r "${EROOT}"usr/share/meganz-sdk/bindings "${S}"/src/MEGASync/mega/
	cmake-utils_src_prepare
	mv -f src/MEGAShellExtDolphin/CMakeLists{_kde5,}.txt
	rm -f src/MEGAShellExtDolphin/megasync-plugin.moc
	use mediainfo || sed -e '/CONFIG += USE_MEDIAINFO/d' \
		-i src/MEGASync/MEGASync.pro
}

src_configure() {
	cd src
	local eqmakeargs=(
		CONFIG$(usex nautilus + -)=with_ext
		CONFIG$(usex thunar + -)=with_thu
		CONFIG-=with_updater
		CONFIG-=with_tools
	)
	eqmake$(usex qt5 5 4) "${eqmakeargs[@]}"
	use dolphin && cmake-utils_src_configure
}

src_compile() {
	cd src
	$(usex qt5 $(qt5_get_bindir) $(qt4_get_bindir))/lrelease \
		MEGASync/MEGASync.pro
	emake
	use dolphin && cmake-utils_src_compile
}

src_install() {
	local DOCS=( CREDITS.md README.md )
	einstalldocs
	emake -C src INSTALL_ROOT="${D}" install
	use dolphin && cmake-utils_src_install
}
