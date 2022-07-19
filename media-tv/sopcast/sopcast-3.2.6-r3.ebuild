# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=7

inherit eutils

MY_PN="sp-auth"

DESCRIPTION="SopCast free P2P Internet TV binary"
LICENSE="SopCast-unknown-license"
HOMEPAGE="http://www.sopcast.com/"
SRC_URI="http://download.sopcast.com/download/${MY_PN}.tgz"

SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RESTRICT="strip"

# All dependencies might not be listed, since the binary blob's homepage only lists libstdc++
RDEPEND="amd64? ( sys-libs/libstdc++-v3[multilib] )
	x86? ( >=virtual/libstdc++-3.3 )"

DEPEND="${RDEPEND}"

S=${WORKDIR}/${MY_PN}

src_install() {
	exeinto usr/bin/
	doexe sp-sc-auth || die "doexe failed"
	dodoc Readme || die "dodoc failed"
}
