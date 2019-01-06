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

S="${WORKDIR}"/"${PN}"

src_install() {
	# default wallpaper
	dodir usr/share/backgrounds/redcore-community
	insinto usr/share/backgrounds/redcore-community
	doins -r defaults/*

	# Wallpapers by pentruprieteni.com, thanks
	dodir usr/share/backgrounds/by_pp
	insinto usr/share/backgrounds/by_pp
	doins -r by_pp/*

	# Photos by Mellita Parjolea, thanks
	dodir usr/share/backgrounds/by_mellita
	insinto usr/share/backgrounds/by_mellita
	doins -r by_mellita/*

	# Wallpapers by Ioan Parjolea (joly), thanks
	dodir usr/share/backgrounds/by_joly
	insinto usr/share/backgrounds/by_joly
	doins -r by_joly/*

	# Wallpapers by Toma S. Muntean, thanks
	dodir usr/share/backgrounds/by_tomas
	insinto usr/share/backgrounds/by_tomas
	doins -r by_tomas/*

	# If you want your wallpapers in here, let me know
	# I will add them only if you own the rights for them
	# venerix [at] redcorelinux [dot] org
}
