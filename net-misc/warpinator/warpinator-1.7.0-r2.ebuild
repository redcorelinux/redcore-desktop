# Copyright 2022-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Share files across the LAN"
HOMEPAGE="https://github.com/linuxmint/warpinator"
SRC_URI="https://github.com/linuxmint/${PN}/archive/refs/tags/master.lmde6.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

inherit meson gnome2-utils xdg

DEPEND="
	dev-libs/gobject-introspection
	dev-python/cryptography
	dev-python/ifaddr
	dev-python/netaddr
	dev-python/netifaces
	dev-python/pynacl
	dev-python/setproctitle
	>=dev-python/python3-xapp-1.6.0
"
RDEPEND="${DEPEND}"
BDEPEND="
	>=dev-util/meson-0.45.0
"

S="${WORKDIR}/${PN}-master.lmde6"

PATCHES=(
	"${FILESDIR}/${PN}-bundled-grpcio-cython3.patch"
	"${FILESDIR}/${PN}-system-paths.patch"
)

src_configure() {
	local emesonargs=(
		-Dinclude-firewall-mod=true
		-Dbundle-zeroconf=true
		-Dbundle-landlock=true
		-Dbundle-grpc=true
	)
	meson_src_configure
}

pkg_postinst() {
	xdg_pkg_postinst
	gnome2_schemas_update
}

pkg_postrm() {
	xdg_pkg_postinst
	gnome2_schemas_update
}
