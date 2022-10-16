# Copyright 2016-2020 Redcore Linux Project
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=7

DESCRIPTION="Native replacement for the Steam runtime using system libraries"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64"
IUSE="screencast"

DEPEND="
	app-emulation/steam
	app-arch/bzip2[abi_x86_32]
	dev-libs/atk[abi_x86_32]
	dev-libs/dbus-glib[abi_x86_32]
	dev-libs/expat[abi_x86_32]
	dev-libs/glib:2[abi_x86_32]
	dev-libs/nspr[abi_x86_32]
	dev-libs/nss[abi_x86_32]
	media-libs/alsa-lib[abi_x86_32]
	media-libs/fontconfig[abi_x86_32]
	media-libs/freetype[abi_x86_32]
	media-libs/libcaca[abi_x86_32]
	media-libs/libpng-compat:1.2[abi_x86_32]
	media-libs/libsdl[abi_x86_32]
	media-libs/libva-compat:1[abi_x86_32]
	media-libs/sdl-image[abi_x86_32]
	media-libs/sdl-mixer[abi_x86_32]
	media-libs/sdl-ttf[abi_x86_32]
	media-libs/libcanberra[abi_x86_32]
	media-libs/libsdl2[abi_x86_32]
	media-libs/sdl2-image[abi_x86_32]
	media-libs/sdl2-mixer[abi_x86_32]
	media-libs/sdl2-ttf[abi_x86_32]
	media-libs/mesa[abi_x86_32]
	media-libs/openal[abi_x86_32]
	net-libs/libnm-glib[abi_x86_32]
	net-misc/curl[abi_x86_32]
	net-print/cups[abi_x86_32]
	sys-apps/dbus[abi_x86_32,X]
	sys-libs/libudev-compat[abi_x86_32]
	sys-libs/zlib[abi_x86_32]
	virtual/jpeg[abi_x86_32]
	virtual/opengl[abi_x86_32]
	virtual/libusb[abi_x86_32]
	x11-libs/gdk-pixbuf[abi_x86_32]
	x11-libs/gtk+:2[abi_x86_32,cups]
	x11-libs/libdrm[abi_x86_32]
	x11-libs/libICE[abi_x86_32]
	x11-libs/libSM[abi_x86_32]
	x11-libs/libvdpau[abi_x86_32]
	x11-libs/libX11[abi_x86_32]
	x11-libs/libXScrnSaver[abi_x86_32]
	x11-libs/libXcomposite[abi_x86_32]
	x11-libs/libXcursor[abi_x86_32]
	x11-libs/libXdamage[abi_x86_32]
	x11-libs/libXext[abi_x86_32]
	x11-libs/libXfixes[abi_x86_32]
	x11-libs/libXi[abi_x86_32]
	x11-libs/libXinerama[abi_x86_32]
	x11-libs/libXrandr[abi_x86_32]
	x11-libs/libXrender[abi_x86_32]
	x11-libs/libXtst[abi_x86_32]
	x11-libs/pango[abi_x86_32]
"
RDEPEND="${DEPEND}
	screencast? ( media-video/pipewire )
	!screencast? ( media-libs/libpipewire[abi_x86_32] )
	|| (
	media-video/pipewire
	media-sound/pulseaudio-daemon
	media-sound/pulseaudio[daemon(+)] )
"

S="${FILESDIR}"

src_install() {
	dobin redcore-steam-native
	insinto usr/share/applications
	doins "${PN}".desktop
}
