# Copyright 2006-2024 Redcore Linux Project
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop pax-utils readme.gentoo-r1 xdg-utils

DESCRIPTION="Modifications to Chromium for removing Google integration and enhancing privacy"
HOMEPAGE="https://www.chromium.org/Home https://github.com/ungoogled-software/ungoogled-chromium"
SRC_URI="http://mirrors.redcorelinux.org/redcorelinux/amd64/distfiles/${PN}_${PV}-1_linux.tar.xz"
RESTRICT="binchecks mirror strip"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"
IUSE="qt5 qt6 +suid +widevine"

CDEPEND="
	app-accessibility/at-spi2-core
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/libxslt
	dev-libs/nspr
	>=dev-libs/icu-71.1:=
	>=dev-libs/libxml2-2.9.4-r3[icu]
	>=dev-libs/nss-3.26
	media-libs/fontconfig
	media-libs/freetype
	media-libs/libjpeg-turbo
	media-libs/libpng
	media-libs/libpulse
	media-libs/libva
	media-libs/lcms
	media-libs/flac
	>=media-libs/alsa-lib-1.0.19
	>=media-libs/libwebp-0.4.0
	>=net-print/cups-1.3.11
	sys-apps/dbus
	sys-apps/pciutils
	sys-libs/zlib[minizip]
	x11-libs/cairo
	x11-libs/pango
	x11-libs/gtk+:3[X]
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXcursor
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXrandr
	x11-libs/libXrender
	x11-libs/libXtst
	x11-libs/libxcb
	>=x11-libs/libXi-1.6.0
	virtual/udev
	qt5? (
		dev-qt/qtcore:5
		dev-qt/qtgui:5[X]
		dev-qt/qtwidgets:5
	)
	qt6? ( dev-qt/qtbase:6[gui,widgets] )
	widevine? ( www-plugins/chrome-binary-plugins )
"

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
S="${WORKDIR}/${PN}_${PV}-1_linux"

src_install() {
	local CHROMIUM_HOME="/opt/chromium-browser"
	dodir "${CHROMIUM_HOME}"

	exeinto "${CHROMIUM_HOME}"
	for i in chrome chrome_crashpad_handler chromedriver chrome_sandbox chrome-wrapper xdg-mime xdg-settings; do
		doexe $i || die
	done
	doexe "${FILESDIR}"/chromium-launcher.sh

	insinto "${CHROMIUM_HOME}"
	for i in *.bin *.pak *.so *.so.1 icudtl.dat; do
		doins $i || die
	done
	doins -r locales
	doins -r resources
	doins vk_swiftshader_icd.json

	dosym "${CHROMIUM_HOME}/chromium-launcher.sh" /usr/bin/chromium-browser
	dosym "${CHROMIUM_HOME}/chromium-launcher.sh" /usr/bin/chromium

	dodir /etc/chromium
	insinto /etc/chromium
	newins "${FILESDIR}"/chromium.default default

	if ! use qt5; then
		rm "${ED}"/"${CHROMIUM_HOME}"/libqt5_shim.so || die
	else
		fperms 0755 "${CHROMIUM_HOME}"/libqt5_shim.so || die
	fi

	if ! use qt6; then
		rm "${ED}"/"${CHROMIUM_HOME}"/libqt6_shim.so || die
	else
		fperms 0755 "${CHROMIUM_HOME}"/libqt6_shim.so || die
	fi

	if use widevine; then
		dosym ../../usr/$(get_libdir)/chromium-browser/WidevineCdm "${CHROMIUM_HOME}"/WidevineCdm
	fi

	pax-mark m "${CHROMIUM_HOME}"/chrome
	use suid && fperms 4711 "${CHROMIUM_HOME}"/chrome_sandbox

	newicon -s 48 product_logo_48.png chromium-browser.png

	local mime_types="text/html;text/xml;application/xhtml+xml;"
	mime_types+="x-scheme-handler/http;x-scheme-handler/https;"
	mime_types+="x-scheme-handler/ftp;"
	mime_types+="x-scheme-handler/mailto;x-scheme-handler/webcal;"

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
