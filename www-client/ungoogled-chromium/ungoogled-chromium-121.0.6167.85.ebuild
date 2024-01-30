# Copyright 2006-2024 Redcore Linux Project
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop readme.gentoo-r1 xdg-utils

DESCRIPTION="Modifications to Chromium for removing Google integration and enhancing privacy"
HOMEPAGE="https://www.chromium.org/Home https://github.com/ungoogled-software/ungoogled-chromium"
SRC_URI="http://mirrors.redcorelinux.org/redcorelinux/amd64/distfiles/${PN}_${PV}-1.1_linux.tar.xz"
RESTRICT="mirror"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

CDEPEND="
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXcursor
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	>=x11-libs/libXi-1.6.0
	x11-libs/libXrandr
	x11-libs/libXrender
	x11-libs/libXtst
	x11-libs/libxcb
	media-libs/libva
	>=net-print/cups-1.3.11
	dev-libs/expat
	dev-libs/glib:2
	>=dev-libs/libxml2-2.9.4-r3[icu]
	dev-libs/nspr
	>=dev-libs/nss-3.26
	>=media-libs/alsa-lib-1.0.19
	media-libs/fontconfig
	media-libs/freetype
	media-libs/libjpeg-turbo
	media-libs/libpng
	media-libs/libpulse
	sys-apps/dbus
	sys-apps/pciutils
	virtual/udev
	x11-libs/cairo
	x11-libs/pango
	media-libs/flac
	>=media-libs/libwebp-0.4.0
	sys-libs/zlib[minizip]
	app-accessibility/at-spi2-core
	x11-libs/gtk+:3[X]
	media-libs/lcms
	dev-libs/libxslt
	>=dev-libs/icu-71.1:="

RDEPEND="${CDEPEND}
	x11-misc/xdg-utils
	virtual/opengl
	virtual/ttf-fonts
	!www-client/chromium"

DISABLE_AUTOFORMATTING="yes"
DOC_CONTENTS="
Some web pages may require additional fonts to display properly.
Try installing some of the following packages if some characters
are not displayed properly:
- media-fonts/arphicfonts
- media-fonts/droid
- media-fonts/ipamonafont
- media-fonts/noto
- media-fonts/noto-emoji
- media-fonts/ja-ipafonts
- media-fonts/takao-fonts
- media-fonts/wqy-microhei
- media-fonts/wqy-zenhei

To fix broken icons on the Downloads page, you should install an icon
theme that covers the appropriate MIME types, and configure this as your
GTK+ icon theme.

For native file dialogs in KDE, install kde-apps/kdialog."

QA_PREBUILT="*"
S="${WORKDIR}/${PN}_${PV}-1.1_linux"

src_install() {
	local CHROMIUM_HOME="/opt/chromium-browser"
	dodir "${CHROMIUM_HOME}"
	exeinto "${CHROMIUM_HOME}"
	doexe "${FILESDIR}"/chromium-launcher.sh
	doexe chrome
	doexe chrome_crashpad_handler
	doexe chromedriver
	doexe chrome_sandbox
	doexe chrome-wrapper
	doexe xdg-mime
	doexe xdg-settings
	fperms 4711 "${CHROMIUM_HOME}"/chrome_sandbox

	insinto "${CHROMIUM_HOME}"
	doins *.bin
	doins *.pak
	doins *.so
	doins *.so.1
	doins icudtl.dat
	doins -r locales
	doins -r resources
	doins vk_swiftshader_icd.json

	dosym "${CHROMIUM_HOME}/chromium-launcher.sh" /usr/bin/chromium-browser
	dosym "${CHROMIUM_HOME}/chromium-launcher.sh" /usr/bin/chromium

	dodir /etc/chromium
	insinto /etc/chromium
	newins "${FILESDIR}"/chromium.default default

	newicon -s 48 product_logo_48.png chromium-browser.png

	local mime_types="text/html;text/xml;application/xhtml+xml;"
	mime_types+="x-scheme-handler/http;x-scheme-handler/https;" # bug #360797
	mime_types+="x-scheme-handler/ftp;" # bug #412185
	mime_types+="x-scheme-handler/mailto;x-scheme-handler/webcal;" # bug #416393

	make_desktop_entry \
		chromium-browser \
		"Chromium Browser (unGoogled)" \
		chromium-browser \
		"Network;WebBrowser" \
		"MimeType=${mime_types}\nStartupWMClass=chromium-browser"
	sed -e "/^Exec/s/$/ %U/" -i "${ED}"/usr/share/applications/*.desktop || die

	dodir /usr/share/gnome-control-center/default-apps
	insinto /usr/share/gnome-control-center/default-apps
	doins "${FILESDIR}"/chromium-browser.xml

	readme.gentoo_create_doc
}

pkg_postrm() {
	xdg_icon_cache_update
	xdg_desktop_database_update
}

pkg_postinst() {
	elog "VA-API is disabled by default at runtime. You have to enable it"
	elog "by adding --enable-features=VaapiVideoDecoder and "
	elog "--disable-features=UseChromeOSDirectVideoDecoder to CHROMIUM_FLAGS"
	elog "in /etc/chromium/default."

	xdg_icon_cache_update
	xdg_desktop_database_update
	readme.gentoo_print_elog
}
