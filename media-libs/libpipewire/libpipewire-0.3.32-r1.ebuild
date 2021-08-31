# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

PYTHON_COMPAT=( python3_{7..10} )

inherit meson-multilib optfeature python-any-r1 udev

MY_PN="pipewire"

SRC_URI="https://gitlab.freedesktop.org/${MY_PN}/${MY_PN}/-/archive/${PV}/${MY_PN}-${PV}.tar.gz"
KEYWORDS="~amd64 ~arm ~arm64 ~ppc ~ppc64 ~x86"

DESCRIPTION="Pipewire client libraries"
HOMEPAGE="https://pipewire.org/"

LICENSE="MIT LGPL-2.1+ GPL-2"
SLOT="0/0.3"
IUSE="bluetooth doc extra gstreamer jack-client jack-sdk pipewire-alsa systemd test v4l"

REQUIRED_USE="jack-sdk? ( !jack-client )"

RESTRICT="!test? ( test )"

BDEPEND="
	app-doc/xmltoman
	virtual/pkgconfig
	${PYTHON_DEPS}
	doc? (
		app-doc/doxygen
		media-gfx/graphviz
	)
"
RDEPEND="
	media-libs/alsa-lib
	sys-apps/dbus[${MULTILIB_USEDEP}]
	sys-libs/ncurses:=[unicode(+)]
	virtual/libintl[${MULTILIB_USEDEP}]
	virtual/libudev[${MULTILIB_USEDEP}]
	bluetooth? (
		media-libs/fdk-aac
		media-libs/libldac
		media-libs/libopenaptx
		media-libs/sbc
		>=net-wireless/bluez-4.101:=
	)
	extra? (
		>=media-libs/libsndfile-1.0.20
	)
	gstreamer? (
		>=dev-libs/glib-2.32.0:2
		>=media-libs/gstreamer-1.10.0:1.0
		media-libs/gst-plugins-base:1.0
	)
	jack-client? ( >=media-sound/jack2-1.9.10:2[dbus] )
	jack-sdk? (
		!media-sound/jack-audio-connection-kit
		!media-sound/jack2
	)
	pipewire-alsa? (
		>=media-libs/alsa-lib-1.1.7[${MULTILIB_USEDEP}]
		|| (
			media-plugins/alsa-plugins[-pulseaudio]
			!media-plugins/alsa-plugins
		)
	)
	!pipewire-alsa? ( media-plugins/alsa-plugins[${MULTILIB_USEDEP},pulseaudio] )
	systemd? ( sys-apps/systemd )
	v4l? ( media-libs/libv4l )
	!!media-video/pipewire
"

DEPEND="${RDEPEND}"

PATCHES=(
	"${FILESDIR}"/${MY_PN}-0.3.25-enable-failed-mlock-warning.patch
	"${FILESDIR}"/${MY_PN}-0.3.31-revert-openaptx-restriction.patch
)

S="${WORKDIR}/${MY_PN}-${PV}"

src_prepare() {
	default

	if ! use systemd; then
		eapply "${FILESDIR}"/${MY_PN}-0.3.31-non-systemd-integration.patch
	fi
}

multilib_src_configure() {
	local emesonargs=(
		-Ddocdir="${EPREFIX}"/usr/share/doc/${PF}
		$(meson_native_use_feature doc docs)
		$(meson_native_enabled examples) # Disabling this implicitly disables -Dmedia-session
		$(meson_native_enabled media-session)
		$(meson_native_enabled man)
		$(meson_feature test tests)
		-Dinstalled_tests=disabled # Matches upstream; Gentoo never installs tests
		$(meson_native_use_feature gstreamer)
		$(meson_native_use_feature gstreamer gstreamer-device-provider)
		$(meson_native_use_feature systemd)
		-Dsystemd-system-service=disabled # Matches upstream
		$(meson_native_use_feature systemd systemd-user-service)
		$(meson_feature pipewire-alsa) # Allows integrating ALSA apps into PW graph
		-Dspa-plugins=enabled
		-Dalsa=enabled # Allows using kernel ALSA for sound I/O (-Dmedia-session depends on this)
		-Daudiomixer=enabled # Matches upstream
		-Daudioconvert=enabled # Matches upstream
		$(meson_native_use_feature bluetooth bluez5)
		$(meson_native_use_feature bluetooth bluez5-backend-hsp-native)
		$(meson_native_use_feature bluetooth bluez5-backend-hfp-native)
		$(meson_native_use_feature bluetooth bluez5-backend-ofono)
		$(meson_native_use_feature bluetooth bluez5-backend-hsphfpd)
		$(meson_native_use_feature bluetooth bluez5-codec-aac)
		$(meson_native_use_feature bluetooth bluez5-codec-aptx)
		$(meson_native_use_feature bluetooth bluez5-codec-ldac)
		-Dcontrol=enabled # Matches upstream
		-Daudiotestsrc=enabled # Matches upstream
		-Dffmpeg=disabled # Disabled by upstream and no major developments to spa/plugins/ffmpeg/ since May 2020
		-Dpipewire-jack=enabled # Allows integrating JACK apps into PW graph
		$(meson_native_use_feature jack-client jack) # Allows PW to act as a JACK client
		$(meson_feature jack-sdk jack-devel)
		$(usex jack-sdk "-Dlibjack-path=${EPREFIX}/usr/$(get_libdir)" '')
		-Dsupport=enabled # Miscellaneous/common plugins, such as null sink
		-Devl=disabled # Matches upstream
		-Dtest=disabled # fakesink and fakesource plugins
		$(meson_native_use_feature v4l v4l2)
		-Dlibcamera=disabled # libcamera is not in Portage tree
		-Dvideoconvert=enabled # Matches upstream
		-Dvideotestsrc=enabled # Matches upstream
		-Dvolume=enabled # Matches upstream
		-Dvulkan=disabled # Uses pre-compiled Vulkan compute shader to provide a CGI video source (dev thing; disabled by upstream)
		$(meson_native_use_feature extra pw-cat)
		-Dudev=enabled
		-Dudevrulesdir="${EPREFIX}$(get_udevdir)/rules.d"
		-Dsdl2=disabled # Controls SDL2 dependent code (currently only examples when -Dinstalled_tests=enabled which we never install)
		$(meson_native_use_feature extra sndfile) # Enables libsndfile dependent code (currently only pw-cat)
	)

	meson_src_configure
}

multilib_src_install() {
	meson_src_install

	# We only need some libraries, trim out the rest
	rm -rvf ${D}/lib
	rm -rvf ${D}/usr/bin
	rm -rvf ${D}/usr/include
	rm -rvf ${D}/usr/$(get_libdir)/alsa-lib
	rm -rvf ${D}/usr/$(get_libdir)/gstreamer-1.0
	rm -rvf ${D}/usr/$(get_libdir)/pipewire-0.3/jack
	rm -rfv ${D}/usr/$(get_libdir)/pkgconfig
	rm -rvf ${D}/usr/share
}
