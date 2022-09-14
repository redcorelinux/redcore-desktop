# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit meson multilib-minimal

DESCRIPTION="Helper for enabling better Steam integration on Linux"
HOMEPAGE="https://github.com/clearlinux/linux-steam-integration"
SRC_URI="https://github.com/clearlinux/"${PN}"/releases/download/v"${PV}"/"${P}".tar.xz"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

RDEPEND="app-emulation/steam
	net-libs/libnm-glib"
DEPEND="x11-libs/gtk+:3
	virtual/pkgconfig"

PATCHES=( "${FILESDIR}"/bzip2.patch )

multilib_src_configure() {
	local emesonargs=(
		-Dwith-shim=co-exist \
		-Dwith-frontend=true \
		-Dwith-steam-binary=/usr/bin/steam \
		-Dwith-new-libcxx-abi=true
	)
	meson_src_configure
}

multilib_src_compile() {
	meson_src_compile
}

multilib_src_install() {
	meson_src_install
}
