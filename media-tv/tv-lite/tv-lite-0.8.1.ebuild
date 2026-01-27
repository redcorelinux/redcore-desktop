# Copyright 2024 Redcore Linux Project
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

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
	media-video/vlc
	net-misc/curl
	net-misc/yt-dlp
	sys-apps/util-linux
	x11-libs/wxGTK:3.2-gtk3
	sopcast? ( media-tv/sopcast )
	"
BDEPEND="${DEPEND}"

S="${WORKDIR}/${P}/src"

src_configure() {
	local mycmakeargs=(
		-DWX_CONFIG=wx-config
	)
	cmake_src_configure
}
