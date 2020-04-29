# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=6
EGIT_REPO_URI="https://pagure.io/redcore/redcore-skel.git"

inherit eutils git-r3 fdo-mime

DESCRIPTION="Redcore Linux skel tree"
HOMEPAGE="https://redcorelinux.org"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""
DEPEND=""
RDEPEND="
	media-fonts/roboto
	x11-themes/material-icon-theme
	x11-themes/redcore-theme
	x11-themes/redcore-artwork-community
	x11-themes/redcore-artwork-core"

S="${WORKDIR}/${P}"

src_install () {
	dodir etc/skel
	insinto etc/skel
	doins -r skel/*
	doins -r skel/.*

	dodir usr/share/desktop-directories
	insinto usr/share/desktop-directories
	doins "${FILESDIR}"/menu/xdg/*.directory

	dodir usr/share/redcore
	insinto usr/share/redcore
	doins -r "${FILESDIR}"/menu/*

	doicon "${FILESDIR}"/menu/img/redcore-weblink.png

	dodir etc/xdg/autostart
	insinto etc/xdg/autostart
	doins "${FILESDIR}"/loginsound.desktop

	dodir usr/share/sounds
	insinto usr/share/sounds
	doins "${FILESDIR}"/redcore.ogg

	rm -rf ${D}etc/.git
}

pkg_postinst() {
	if [ -x "/usr/bin/xdg-desktop-menu" ]; then
		xdg-desktop-menu install \
			/usr/share/redcore/xdg/redcore-redcore.directory \
			/usr/share/redcore/xdg/*.desktop
	fi

	fdo-mime_desktop_database_update
}

pkg_prerm() {
	if [ -x "/usr/bin/xdg-desktop-menu" ]; then
		xdg-desktop-menu uninstall /usr/share/redcore/xdg/redcore-redcore.directory /usr/share/redcore/xdg/*.desktop
	fi
}
