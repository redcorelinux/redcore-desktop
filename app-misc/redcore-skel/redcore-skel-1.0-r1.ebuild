# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=6
EGIT_REPO_URI="https://gitlab.com/redcore/redcore-skel.git"

inherit eutils git-r3 fdo-mime

DESCRIPTION="Redcore Linux skel tree"
HOMEPAGE="http://redcorelinux.org"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""
DEPEND=""
RDEPEND="
	x11-themes/redcore-theme
	x11-themes/numix-icon-theme
	x11-themes/numix-icon-theme-circle
	x11-themes/redcore-artwork-community
	x11-themes/redcore-artwork-core"

src_install () {
	dodir /etc/xdg/menus
	cp "${S}"/* "${D}"/etc/ -Ra
	chown root:root "${D}"/etc/skel -R

	dodir /usr/share/desktop-directories
	cp "${FILESDIR}"/3.0/xdg/*.directory "${D}"/usr/share/desktop-directories/
	dodir /usr/share/redcore
	cp -a "${FILESDIR}"/3.0/* "${D}"/usr/share/redcore/
	doicon "${FILESDIR}"/3.0/img/redcore-weblink.png
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
