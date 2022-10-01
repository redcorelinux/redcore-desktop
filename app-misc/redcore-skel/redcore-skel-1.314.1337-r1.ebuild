# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=6
EGIT_REPO_URI="https://pagure.io/redcore/redcore-skel.git"

inherit eutils git-r3

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
	x11-themes/numix-icon-theme
	x11-themes/numix-icon-theme-circle
	x11-themes/redcore-theme
	x11-themes/redcore-artwork-community
	x11-themes/redcore-artwork-core
	x11-themes/redcore-artwork-grub"

S="${WORKDIR}/${P}"

src_install () {
	dodir etc/skel
	insinto etc/skel
	doins -r skel/*
	doins -r skel/.*

	doicon "${FILESDIR}"/redcore-weblink.svg

	dodir etc/xdg/autostart
	insinto etc/xdg/autostart
	doins "${FILESDIR}"/loginsound.desktop

	dodir usr/share/sounds
	insinto usr/share/sounds
	doins "${FILESDIR}"/redcore.ogg

	rm -rf ${D}etc/.git
}
