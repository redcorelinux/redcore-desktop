# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=8
EGIT_REPO_URI="https://codeberg.org/redcore/redcore-skel.git"

inherit desktop git-r3

DESCRIPTION="Redcore Linux skel tree"
HOMEPAGE="https://redcorelinux.org"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""
DEPEND=""
RDEPEND="
	media-fonts/fontawesome
	media-fonts/roboto
	x11-themes/material-icon-theme
	x11-themes/redcore-artwork-community
	x11-themes/redcore-artwork-core
	x11-themes/redcore-artwork-grub
	x11-themes/redcore-theme
	x11-themes/redcore-theme-sddm"
S="${WORKDIR}/${P}/skel"

src_install () {
	local SKEL_HOME="/etc/skel"
	dodir "${SKEL_HOME}"
	insinto "${SKEL_HOME}"
	doins -r *
	doins -r .*
	fperms 755 "${SKEL_HOME}"/.config/autostart/scripts/disable-dpms.sh
	fperms 755 "${SKEL_HOME}"/.config/qtile/scripts/autostart.sh

	local XDG_HOME="/etc/xdg"
	dodir "${XDG_HOME}"/autostart
	insinto "${XDG_HOME}"/autostart
	doins "${FILESDIR}"/loginsound.desktop

	local SND_HOME="/usr/share/sounds"
	dodir "${SND_HOME}"
	insinto "${SND_HOME}"
	doins "${FILESDIR}"/redcore.ogg

	doicon "${FILESDIR}"/redcore-weblink.svg

	rm -rvf "${D}"/etc/.git
}
