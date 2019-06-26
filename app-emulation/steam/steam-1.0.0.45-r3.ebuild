# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2


EAPI=6

inherit eutils

DESCRIPTION="Digital distribution client bootstrap package"
HOMEPAGE="http://steampowered.com/"
SRC_URI="http://repo.steampowered.com/${PN}/pool/${PN}/s/${PN}/${PN}_${PV}.tar.gz"

LICENSE="custom"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="
	virtual/ttf-fonts
	dev-util/desktop-file-utils
	x11-themes/hicolor-icon-theme
	net-misc/curl
	sys-apps/dbus
	sys-apps/gentoo-functions
	media-libs/freetype
	media-libs/libtxc_dxtn
	x11-libs/gdk-pixbuf
	gnome-extra/zenity
	amd64? (
		media-libs/alsa-lib[abi_x86_32(-)]
		media-libs/mesa[abi_x86_32(-)]
		x11-libs/libX11[abi_x86_32(-)]
		x11-libs/libxcb[abi_x86_32(-)]
	)
	x86? (
		media-libs/alsa-lib
		media-libs/mesa
		x11-libs/libX11
		x11-libs/libxcb
	)"

S=${WORKDIR}/${PN}

PATCHES=( "${FILESDIR}/redcore-${PN}.patch" )

src_install() {
	emake DESTDIR="${D}" install
	dobin "${FILESDIR}"/redcore-steam
	rm -rf "${D}"/usr/bin/steamdeps
	dosym /bin/true /usr/bin/steamdeps
	rm -rf "${D}"/usr/share/doc/"${PN}"
	dodoc steam_install_agreement.txt
}
