# Copyright 1999-2023 Gentoo Authors
# Copyright 2025 Redcore Linux Project
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake xdg udev

MY_PV=$(ver_cut 1-2)
DESCRIPTION="Advanced Digital DJ tool based on Qt"
HOMEPAGE="https://mixxx.org/"
SRC_URI="https://github.com/mixxxdj/${PN}/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"
KEYWORDS="~amd64"
LICENSE="GPL-2"
SLOT="0"
IUSE="aac ffmpeg hid keyfinder lv2 modplug mp3 mp4 opus qtkeychain shout wavpack"

RDEPEND="
	dev-cpp/benchmark
	dev-cpp/ms-gsl
	dev-db/sqlite
	dev-libs/glib:2
	dev-libs/protobuf:=
	dev-qt/qt5compat:6
	dev-qt/qtbase:6[dbus,gui,network,opengl,sql,widgets,xml]
	dev-qt/qtdeclarative:6
	dev-qt/qtshadertools:6
	dev-qt/qtsvg:6
	dev-qt/qttools:6
	media-libs/chromaprint
	media-libs/flac:=
	media-libs/libebur128
	media-libs/libid3tag:=
	media-libs/libogg
	media-libs/libsndfile
	media-libs/libsoundtouch
	media-libs/libvorbis
	media-libs/portaudio[alsa]
	media-libs/portmidi
	media-libs/rubberband
	media-libs/taglib
	media-libs/vamp-plugin-sdk
	media-sound/lame
	sci-libs/fftw:3.0=
	sys-power/upower
	virtual/glu
	virtual/libusb:1
	virtual/opengl
	virtual/udev
	x11-libs/libX11
	aac? (
		media-libs/faad2
		media-libs/libmp4v2
	)
	ffmpeg? ( media-video/ffmpeg:= )
	hid? ( dev-libs/hidapi )
	keyfinder? ( media-libs/libkeyfinder )
	lv2? ( media-libs/lilv )
	modplug? ( media-libs/libmodplug )
	mp3? ( media-libs/libmad )
	mp4? ( media-libs/libmp4v2:= )
	opus? (	media-libs/opusfile )
	qtkeychain? ( dev-libs/qtkeychain:=[qt6(+)] )
	wavpack? ( media-sound/wavpack )
"
	# libshout-idjc-2.4.6 is required. Please check and re-add once it's
	# available in ::gentoo
	# Meanwhile we're using the bundled libshout-idjc. See bug #775443
	#shout? ( >=media-libs/libshout-idjc-2.4.6 )

DEPEND="${RDEPEND}
	dev-qt/qtbase:6[concurrent]
"
BDEPEND="
	dev-qt/qtbase:6[test]
	virtual/pkgconfig
"

PATCHES=(
	"${FILESDIR}"/${PN}-2.3.0-docs.patch
	"${FILESDIR}"/${PN}-2.3.0-cmake.patch
)

src_configure() {
	local mycmakeargs=(
		# Not available on Linux yet and requires additional deps
		-DBATTERY="off"
		-DBROADCAST="$(usex shout on off)"
		-DCCACHE_SUPPORT="off"
		-DFAAD="$(usex aac on off)"
		-DFFMPEG="$(usex ffmpeg on off)"
		-DHID="$(usex hid on off)"
		-DINSTALL_USER_UDEV_RULES=OFF
		-DKEYFINDER="$(usex keyfinder on off)"
		-DLILV="$(usex lv2 on off)"
		-DMAD="$(usex mp3 on off)"
		-DMODPLUG="$(usex modplug on off)"
		-DOPTIMIZE="off"
		-DOPUS="$(usex opus on off)"
		-DQTKEYCHAIN="$(usex qtkeychain on off)"
		-DVINYLCONTROL="on"
		-DWAVPACK="$(usex wavpack on off)"
	)

	cmake_src_configure
}

src_install() {
	cmake_src_install
	udev_newrules "${S}"/res/linux/mixxx-usb-uaccess.rules 69-mixxx-usb-uaccess.rules
	dodoc README.md CHANGELOG.md
}

pkg_postinst() {
	xdg_pkg_postinst
	udev_reload
}

pkg_postrm() {
	xdg_pkg_postrm
	udev_reload
}
