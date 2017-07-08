# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils

DESCRIPTION="Redcore Linux branding component for Calamares"
HOMEPAGE="http://redcorelinux.org"
SRC_URI="http://mirror.math.princeton.edu/pub/redcorelinux/distfiles/${P}.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

RDEPEND="app-admin/calamares"

S="${WORKDIR}/${P}"

src_install() {
	dodir /etc/calamares/branding/redcore_branding || die
	insinto /etc/calamares/branding/redcore_branding || die
	doins -r "${S}"/* || die
}
