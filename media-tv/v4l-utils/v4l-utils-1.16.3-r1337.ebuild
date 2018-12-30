# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit flag-o-matic udev xdg-utils

DESCRIPTION="Separate utilities ebuild from upstream v4l-utils package"
HOMEPAGE="http://git.linuxtv.org/v4l-utils.git"
SRC_URI="http://linuxtv.org/downloads/v4l-utils/${P}.tar.bz2"

LICENSE="GPL-2+ LGPL-2.1+"
SLOT="0"
KEYWORDS="~amd64"
IUSE="jpeg qt5"

RDEPEND="
	jpeg? ( >=virtual/jpeg-0-r2:0=[${MULTILIB_USEDEP}]
	>=media-libs/libv4l-${PV}[jpeg]
	qt5? (
		dev-qt/qtcore:5
		dev-qt/qtgui:5
		dev-qt/qtopengl:5
		virtual/opengl
		media-libs/alsa-lib
	)
	virtual/libudev
	!media-tv/v4l2-ctl
	!<media-tv/ivtv-utils-1.4.0-r2"
DEPEND="${RDEPEND}
	sys-devel/gettext
	virtual/pkgconfig"

PATCHES=( "${FILESDIR}/sdlcam-only-build-if-using-jpeg.patch" )

src_configure() {
	if use qt5; then
		append-cxxflags -std=c++11
		local qt5_paths=( \
			MOC="$(pkg-config --variable=host_bins Qt5Core)/moc" \
			UIC="$(pkg-config --variable=host_bins Qt5Core)/uic" \
			RCC="$(pkg-config --variable=host_bins Qt5Core)/rcc" \
		)
	fi
	# Hard disable the flags that apply only to the libs.
	econf \
		--disable-static \
		$(use_enable qt5 qv4l2) \
		--with-udevdir="$(get_udevdir)" \
		$(use_with jpeg) \
		"${qt5_paths[@]}"
}

src_install() {
	emake -C utils DESTDIR="${D}" install
	emake -C contrib DESTDIR="${D}" install

	dodoc README
	newdoc utils/libv4l2util/TODO TODO.libv4l2util
	newdoc utils/libmedia_dev/README README.libmedia_dev
	newdoc utils/dvb/README README.dvb
	newdoc utils/v4l2-compliance/fixme.txt fixme.txt.v4l2-compliance
}
