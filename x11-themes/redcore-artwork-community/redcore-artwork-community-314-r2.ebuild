# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit eutils git-r3

DESCRIPTION="Redcore Linux Community Wallpapers"
HOMEPAGE="https://redcorelinux.org"

EGIT_REPO_URI="https://gitlab.com/redcore/redcore-wallpapers.git"
EGIT_BRANCH="master"

LICENSE=""
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

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

	# Wallpapers by Toma S. Muntean, thanks
	dodir usr/share/backgrounds/by_tomas
	insinto usr/share/backgrounds/by_tomas
	doins -r by_tomas/*

	# If you want your wallpapers in here, let me know
	# I will add them only if you own the rights for them
	# venerix [at] redcorelinux [dot] org
}
