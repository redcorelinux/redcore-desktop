# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

DESCRIPTION="Redcore Linux Community Wallpapers"
HOMEPAGE="http://redcorelinux.org"
SRC_URI="http://mirror.math.princeton.edu/pub/redcorelinux/distfiles/${PN}.tar.xz"

LICENSE=""
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

src_install() {
	# Wallpapers by V3n3RiX
	dodir usr/share/backgrounds/redcore-community
	insinto usr/share/backgrounds/redcore-community
	doins -r by_venerix/*

	# Wallpapers by pentruprieteni.com, thanks
	dodir usr/share/backgrounds/by_pp
	insinto usr/share/backgrounds/by_pp
	doins -r by_pp/*

	# Photos by Mellita Parjolea, thanks
	dodir usr/share/backgrounds/by_mellita
	insinto usr/share/backgrounds/by_mellita
	doins -r by_mellita/*

	# If you want your wallpapers in here, let me know
	# I will add them only if you own the rights for them
	# venerix [at] redcorelinux [dot] org
}
