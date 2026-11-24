# Copyright 2026 Redcore Linux Project
# Distributed under the terms of the GNU General Public License v2

EAPI=8

VCPKG_VERSION="2026.10.16"

inherit vcpkg

DESCRIPTION="Lightweight desktop IRC client built with Dear ImGui, GLFW, and Boost.Asio"
HOMEPAGE="https://github.com/victorb64/ImIRC"
SRC_URI+=" https://github.com/victorb64/ImIRC/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Unlicense"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	media-libs/libglvnd
	x11-libs/libX11
	x11-libs/libXcursor
	x11-libs/libXi
	x11-libs/libXinerama
	x11-libs/libXrandr
"
DEPEND="${RDEPEND}"

S="${WORKDIR}/ImIRC-${PV}"

src_configure() {
	VCPKG_TRIPLET="x64-linux-redcore"
	VCPKG_OVERLAY_TRIPLETS="${FILESDIR}/triplets"

	local mycmakeargs=(
		-DBUILD_SHARED_LIBS=OFF
	)

	vcpkg_src_configure
}
