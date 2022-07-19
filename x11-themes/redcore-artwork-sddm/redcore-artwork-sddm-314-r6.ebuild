# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=7

DESCRIPTION="Redcore Linux SDDM Theme"
HOMEPAGE=""
SRC_URI=""

LICENSE="CC-BY-SA"
SLOT="0"
KEYWORDS="amd64 x86"
DEPENDS="
	!x11-themes/redcore-theme-sddm
"
IUSE=""

S="${FILESDIR}"

src_install() {
	dodir usr/share/sddm/themes
	insinto usr/share/sddm/themes
	doins -r ${S}/*
}
