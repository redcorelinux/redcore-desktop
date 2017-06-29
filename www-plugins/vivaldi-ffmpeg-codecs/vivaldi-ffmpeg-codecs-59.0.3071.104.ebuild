# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit eutils

DESCRIPTION="Additional proprietary codecs for vivaldi"
HOMEPAGE="http://ffmpeg.org/"
SRC_URI="https://repo.herecura.eu/herecura/x86_64/${P}-1-x86_64.pkg.tar.xz"

LICENSE="LGPL2.1"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND="www-client/vivaldi"
RDEPEND="${DEPEND}"

S="${WORKDIR}"

src_prepare() {
	:
}

src_compile() {
	:
}

src_install() {
	doins -r ${S}/*
	rm -rf ${ED}usr/lib/debug
}
