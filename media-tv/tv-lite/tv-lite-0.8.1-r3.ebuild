# Copyright 2024 Redcore Linux Project
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake flag-o-matic

DESCRIPTION="IPTV viewer with Sopcast and Acestream handling capabilities."
HOMEPAGE="http://tv-lite.com"
SRC_URI="https://gitlab.com/cburneci/${PN}/-/archive/${PV}/${P}.tar.gz"

LICENSE="GPLv2"
SLOT="0"
KEYWORDS="~amd64"

IUSE="sopcast"

DEPEND="
	dev-libs/rapidjson
	"
RDEPEND="${DEPEND}
	dev-db/sqlite
	media-libs/libvlc:3=
	net-misc/curl
	net-misc/yt-dlp
	sys-apps/util-linux
	x11-libs/wxGTK:3.2-gtk3
	sopcast? ( media-tv/sopcast )
	"
BDEPEND="${DEPEND}"

S="${WORKDIR}/${P}/src"

PATCHES=( "${FILESDIR}"/"${P}-use-libvlc3-compat.patch" )

src_configure() {
	append-cppflags "-I${ESYSROOT}/usr/include/vlc3"
	append-ldflags "-L${ESYSROOT}/usr/$(get_libdir)/vlc3"
	append-ldflags "-Wl,--no-as-needed"

	local mycmakeargs=(
		-DWX_CONFIG=wx-config
		-DCMAKE_LIBRARY_PATH="${ESYSROOT}/usr/$(get_libdir)/vlc3"
		-DCMAKE_SKIP_RPATH=OFF
	)
	cmake_src_configure
}
