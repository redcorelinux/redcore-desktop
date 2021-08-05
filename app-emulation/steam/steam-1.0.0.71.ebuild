# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2


EAPI=6

inherit eutils

DESCRIPTION="Digital distribution client bootstrap package"
HOMEPAGE="http://steampowered.com/"
SRC_URI="http://repo.steampowered.com/"${PN}"/pool/"${PN}"/s/"${PN}"/"${PN}"_"${PV}".tar.gz"

LICENSE="custom"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	dev-util/desktop-file-utils
	gnome-extra/zenity
	media-libs/alsa-lib[abi_x86_32(-)]
	media-libs/freetype[abi_x86_32(-)]
	media-libs/mesa[abi_x86_32(-)]
	net-misc/curl[abi_x86_32(-)]
	sys-apps/dbus[abi_x86_32(-),X]
	sys-apps/gentoo-functions
	virtual/ttf-fonts
	x11-libs/gdk-pixbuf[abi_x86_32(-)]
	x11-libs/libX11[abi_x86_32(-)]
	x11-libs/libxcb[abi_x86_32(-)]
	x11-themes/hicolor-icon-theme"

S="${WORKDIR}"/"${PN}-launcher"

PATCHES=( "${FILESDIR}/redcore-${PN}.patch" )

src_prepare() {
	default
	sed -r 's|("0666")|"0660", TAG+="uaccess"|g' -i subprojects/steam-devices/60-steam-input.rules
	sed -r 's|("misc")|\1, OPTIONS+="static_node=uinput"|g' -i subprojects/steam-devices/60-steam-input.rules
	sed -r 's|(, TAG\+="uaccess")|, MODE="0660"\1|g' -i subprojects/steam-devices/60-steam-vr.rules

	sed -i 's|PrefersNonDefaultGPU=true||g' ${PN}.desktop
	sed -i 's|X-KDE-RunOnDiscreteGpu=true||g' ${PN}.desktop
}

src_install() {
	# make install
	emake DESTDIR="${D}" install

	# inject our wrapper binary
	dobin "${FILESDIR}"/redcore-steam

	# blank steamdeps because apt-get
	rm -rf "${D}"/usr/bin/steamdeps
	dosym /bin/true /usr/bin/steamdeps

	# docs
	rm -rf "${D}"/usr/share/doc/"${PN}"
	dodoc steam_subscriber_agreement.txt

	# udev rules
	insinto usr/lib/udev/rules.d
	newins subprojects/steam-devices/60-steam-input.rules 70-steam-input.rules
	newins subprojects/steam-devices/60-steam-vr.rules 70-steam-vr.rules
}
