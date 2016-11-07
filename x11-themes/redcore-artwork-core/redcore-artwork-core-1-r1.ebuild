# Copyright 2016 Redcore Linux
# Distributed under the terms of the GNU General Public License v2

EAPI=4
inherit eutils mount-boot

DESCRIPTION="Offical Redcore Linux Core Artwork"
HOMEPAGE="http://redcorelinux.org"
SRC_URI="http://redcorelinux.org/distfiles/${CATEGORY}/${PN}/"${PN}"-${PV}.tar.xz"

LICENSE="CCPL-Attribution-ShareAlike-3.0"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE=""
RDEPEND="sys-apps/findutils"

S="${WORKDIR}"/"${PN}"

src_install() {
	# Cursors
	insinto /usr/share/cursors/xorg-x11/
	doins -r "${S}"/mouse/RezoBlue

	# Wallpapers
	insinto /usr/share/backgrounds/
	doins -r "${S}"/background/nature

	# Logos
	insinto /usr/share/pixmaps/
	doins "${S}"/logo/*.png

	# Plymouth theme

	insinto /usr/share/plymouth
	doins "${S}"/plymouth/bizcom.png # back to our bizcom
	insinto /usr/share/plymouth/themes
	doins -r "${S}"/plymouth/themes/redcore

	# Apply our tricks

	insinto /usr/share/cursors/xorg-x11
	dosym RezoBlue /usr/share/cursors/xorg-x11/default || "RezoBlue not found" #set default xcursor
}

pkg_postinst() {
	# mount boot first
	mount-boot_mount_boot_partition

	einfo "Please report bugs or glitches to"
	einfo "V3n3RiX"
}
