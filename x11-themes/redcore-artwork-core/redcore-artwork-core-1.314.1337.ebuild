# Copyright 2016 Redcore Linux
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit eutils git-r3

DESCRIPTION="Offical Redcore Linux Core Artwork"
HOMEPAGE="https://redcorelinux.org"

EGIT_REPO_URI="https://gitlab.com/redcore/redcore-artwork-core.git"
EGIT_BRANCH="master"
EGIT_COMMIT="fc7014337a473ff0b8956ca0b2a37b3a3242eb66"

LICENSE="CCPL-Attribution-ShareAlike-3.0"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE="+splash"
RDEPEND="sys-apps/findutils
	sys-boot/plymouth
	>=x11-themes/hicolor-icon-theme-0.10
	splash? (
		sys-kernel/dracut[splash]
	)"

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
	if use splash; then
		insinto usr/share/plymouth
		doins plymouth/bizcom.png
		insinto usr/share/plymouth/themes
		doins -r plymouth/themes/redcore
	fi
}

_dracut_initramfs_regen() {
	if [ -x $(which dracut) ]; then
		dracut -N -f --no-hostonly-cmdline
	fi
}

pkg_postinst() {
	# regenerate initramfs to include plymouth theme changes
	if [ $(stat -c %d:%i /) == $(stat -c %d:%i /proc/1/root/.) ]; then
		_dracut_initramfs_regen
	fi
}
