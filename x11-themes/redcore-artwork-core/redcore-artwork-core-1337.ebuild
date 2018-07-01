# Copyright 2016 Redcore Linux
# Distributed under the terms of the GNU General Public License v2

EAPI=4
inherit eutils

DESCRIPTION="Offical Redcore Linux Core Artwork"
HOMEPAGE="https://redcorelinux.org"
SRC_URI="http://mirror.math.princeton.edu/pub/redcorelinux/distfiles/${PN}.tar.xz"

LICENSE="CCPL-Attribution-ShareAlike-3.0"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE=""
RDEPEND="sys-apps/findutils"

S="${WORKDIR}"/"${PN}"

src_install() {
	# Cursors
	insinto usr/share/cursors/xorg-x11/
	doins -r mouse/Hacked-Red
	dosym ../../../../usr/share/cursors/xorg-x11/Hacked-Red usr/share/cursors/xorg-x11/default

	# Wallpapers
	insinto usr/share/backgrounds/
	doins -r background/nature

	# Logos
	insinto usr/share/pixmaps/
	doins logo/*.png

	# Plymouth theme
	insinto usr/share/plymouth
	doins plymouth/bizcom.png
	insinto usr/share/plymouth/themes
	doins -r plymouth/themes/redcore
}

pkg_postinst() {
	# regenerate initramfs to include plymouth theme changes
	dracut -N -f --no-hostonly-cmdline
}
