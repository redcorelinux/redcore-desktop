# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit autotools-utils readme.gentoo systemd toolchain-funcs

DESCRIPTION="Graphical boot animation (splash) and logger"
HOMEPAGE="http://cgit.freedesktop.org/plymouth/"
SRC_URI="http://www.freedesktop.org/software/plymouth/releases/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha amd64 ~arm ~ia64 ~ppc ~ppc64 ~sparc ~x86"
IUSE_VIDEO_CARDS="video_cards_intel video_cards_radeon"
IUSE="${IUSE_VIDEO_CARDS} debug gdm +gtk +libkms +pango static-libs"

CDEPEND="
	>=media-libs/libpng-1.2.16
	gtk? (
		dev-libs/glib:2
		>=x11-libs/gtk+-2.12:2 )
	libkms? ( x11-libs/libdrm[libkms] )
	pango? ( >=x11-libs/pango-1.21 )
	video_cards_intel? ( x11-libs/libdrm[video_cards_intel] )
	video_cards_radeon? ( x11-libs/libdrm[video_cards_radeon] )
"
DEPEND="${CDEPEND}
	virtual/pkgconfig
"
# Block due bug #383067
RDEPEND="${CDEPEND}
	virtual/udev
	x11-themes/redcore-artwork-core
"

DOC_CONTENTS="
	Follow the following instructions to set up Plymouth:\n
	http://dev.gentoo.org/~aidecoe/doc/en/plymouth.xml
"

src_prepare() {
	epatch "${FILESDIR}/${PN}-redcore-defaults.patch"
	epatch "${FILESDIR}/${PN}-text-redcore-colors.patch"
	epatch "${FILESDIR}/${PN}-include-sysmacros.patch"
	epatch "${FILESDIR}/${PN}-fix-window-size-with-multiple-heads.patch"

	sed -i 's:/bin/systemd-tty-ask-password-agent:/usr/bin/systemd-tty-ask-password-agent:g' \
		systemd-units/systemd-ask-password-plymouth.service.in || die \
		'ask-password sed failed'
	sed -i 's:/bin/udevadm:/usr/bin/udevadm:g' \
		systemd-units/plymouth-start.service.in || die 'udevadm sed failed'
	autotools-utils_src_prepare
}

src_configure() {
	local myeconfargs=(
		--with-system-root-install=no
		--localstatedir=/var
		--without-rhgb-compat-link
		--disable-systemd-integration
		$(use_enable debug tracing)
		$(use_enable gtk gtk)
		$(use_enable libkms)
		$(use_enable pango)
		$(use_enable gdm gdm-transition)
		$(use_enable video_cards_intel libdrm_intel)
		$(use_enable video_cards_radeon libdrm_radeon)
		)
	autotools-utils_src_configure
}

src_install() {
	autotools-utils_src_install

	# Provided by redcore-artwork-core
	rm "${D}/usr/share/plymouth/bizcom.png"

	# Install compatibility symlinks as some rdeps hardcode the paths
	dosym /usr/bin/plymouth /bin/plymouth
	dosym /usr/sbin/plymouth-set-default-theme /sbin/plymouth-set-default-theme
	dosym /usr/sbin/plymouthd /sbin/plymouthd

	readme.gentoo_create_doc
}
