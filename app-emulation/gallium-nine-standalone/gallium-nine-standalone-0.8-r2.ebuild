# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit meson-multilib toolchain-funcs

MY_PN="wine-nine-standalone"
DESCRIPTION="A standalone version of the WINE parts of Gallium Nine"
HOMEPAGE="https://github.com/iXit/wine-nine-standalone"

if [[ ${PV} = 9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/iXit/${MY_PN}.git"
else
	SRC_URI="https://github.com/iXit/${MY_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	S="${WORKDIR}/${MY_PN}-${PV}"
	KEYWORDS="-* ~amd64 ~x86"
fi

LICENSE="LGPL-2.1+"
SLOT="0"

# We don't put Wine in RDEPEND because you can also use this with
# Steam's Proton.

RDEPEND="
	media-libs/mesa[d3d9,X(+),${MULTILIB_USEDEP}]
	x11-libs/libX11[${MULTILIB_USEDEP}]
	x11-libs/libxcb[${MULTILIB_USEDEP}]
"

DEPEND="
	${RDEPEND}
	virtual/pkgconfig
	virtual/wine[${MULTILIB_USEDEP}]
	>=dev-util/meson-0.50.1
"

PATCHES=(
	"${FILESDIR}"/"${PV}"-bypass_bootstrap.patch
)

bits() {
	if [[ ${ABI} = amd64 ]]; then
		echo 64
	else
		echo 32
	fi
}

multilib_src_configure() {
	local emesonargs=(
		--cross-file "${S}/tools/cross-wine$(bits)"
		--bindir "$(get_libdir)"
		-Ddistro-independent=false
		-Ddri2=false
	)
	meson_src_configure
}

multilib_src_install() {
	meson_src_install
	dobin "${S}"/tools/nine-install.sh || die
}
