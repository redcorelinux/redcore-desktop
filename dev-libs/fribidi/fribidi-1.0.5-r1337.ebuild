# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit meson multilib-minimal

DESCRIPTION="A free implementation of the unicode bidirectional algorithm"
HOMEPAGE="https://fribidi.org/"
SRC_URI="https://github.com/fribidi/fribidi/releases/download/v${PV}/${P}.tar.bz2"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="amd64"
IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}
	virtual/pkgconfig[${MULTILIB_USEDEP}]"

PATCHES=( "${FILESDIR}"/no-config-h.diff )

multilib_src_configure() {
	local emesonargs=(
		-Ddocs=false
	)
	meson_src_configure
}

multilib_src_install() {
	meson_src_install
}
