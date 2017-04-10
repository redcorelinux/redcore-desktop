# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit gnome2 autotools

DESCRIPTION="An adaptive GTK+ theme based on Material Design Guidelines"
HOMEPAGE="https://github.com/tista500/Adapta"

SRC_URI="${HOMEPAGE}/archive/${PV}.tar.gz -> ${P}.tar.gz"
KEYWORDS="amd64 x86"
RESTRICT="mirror"
S="${WORKDIR}/${P}"

LICENSE="GPL-2"
SLOT="0"
IUSE=""

DEPEND="
	x11-libs/gtk+:2
	>=dev-ruby/sass-3.4.21:3.4
	>=dev-ruby/bundler-1.11
	media-gfx/inkscape
	dev-libs/libxml2:2
	sys-process/parallel
"
RDEPEND="${DEPEND}"

src_prepare(){
	eautoreconf
	gnome2_src_prepare
}

src_compile(){
	emake DESTDIR="${D}" || die
}

src_install(){
	emake DESTDIR="${D}" install || die
}
