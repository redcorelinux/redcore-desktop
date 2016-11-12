# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

DESCRIPTION="The snap-confine program helps to launch snappy applications"
HOMEPAGE="http://snapcraft.io/"
SRC_URI="https://github.com/snapcore/${PN}/releases/download/${PV}/${P}.tar.gz"
RESTRICT="mirror"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64"

DEPEND="dev-python/docutils
	sys-devel/autoconf
	sys-devel/automake
	sys-devel/gcc
	sys-devel/make
	virtual/libudev"

src_configure() {
	econf --disable-apparmor
}

src_compile() {
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install
	dodoc README.md PORTING
}
