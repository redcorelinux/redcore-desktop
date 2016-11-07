# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

DESCRIPTION="Redcore Linux Community Wallpapers"
HOMEPAGE="http://redcorelinux.org"

LICENSE=""
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"
S=${FILESDIR}

src_install() {
	dodir "/usr/share/backgrounds/redcore-community" || die
	insinto "/usr/share/backgrounds/redcore-community" || die
	doins -r "${S}"/* || die
}
