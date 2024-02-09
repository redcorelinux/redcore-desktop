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

IUSE="gtk +gtk3 sopcast"
REQUIRED_USE="^^ ( gtk gtk3 )"

DEPEND="
	dev-libs/rapidjson
	"
RDEPEND="${DEPEND}
	dev-db/sqlite
	media-video/vlc
	net-misc/curl
	sys-apps/util-linux
	gtk? ( x11-libs/wxGTK:3.0 )
	gtk3? (
			|| (
				x11-libs/wxGTK:3.2-gtk3
				x11-libs/wxGTK:3.0-gtk3
			)
	)
	sopcast? ( media-tv/sopcast )
	"
BDEPEND="${DEPEND}"

PATCHES=(
	"${FILESDIR}"/"${P}"-sopprotocol.patch
	"${FILESDIR}"/"${P}"-desktopfile-qa.patch
)

S="${WORKDIR}/${P}/src"

src_configure() {
	local mycmakeargs=(
		-DWX_CONFIG=wx-config
	)
	if use gtk; then
		local mycmakeargs+=(
			-DGTKVER=gtk+-2.0
		)
	fi
	cmake_src_configure
}
