# Copyright 2026 Redcore Linux Project
# Distributed under the terms of the GNU General Public License v2

EAPI=8

WX_GTK_VER="3.2-gtk3"
inherit cmake desktop git-r3 multilib wxwidgets xdg

DESCRIPTION="Cross-platform IDE for C/C++, Rust, Python, PHP and Node.js"
HOMEPAGE="https://codelite.org/ https://github.com/eranif/codelite"
EGIT_REPO_URI="https://github.com/eranif/codelite.git"
EGIT_COMMIT="${PV}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="mariadb mysql postgres"
REQUIRED_USE="?? ( mariadb mysql )"

RESTRICT="mirror"

DEPEND="
	app-text/hunspell:=
	dev-libs/boost:=
	dev-libs/libpcre2:=
	net-libs/libssh:=
	dev-db/sqlite:3
	x11-libs/gtk+:3
	x11-libs/wxGTK:${WX_GTK_VER}[opengl,webkit]
	mariadb? ( dev-db/mariadb-connector-c:= )
	mysql? ( dev-db/mysql-connector-c:= )
	postgres? ( dev-db/postgresql:= )
"
RDEPEND="${DEPEND}"
BDEPEND="
	virtual/pkgconfig
"

PATCHES=( "${FILESDIR}"/codelite-tree-context-menu-crash.patch )

src_prepare() {
	sed -i -e "s|set(CL_INSTALL_LIBDIR \"lib\")|set(CL_INSTALL_LIBDIR \"$(get_libdir)\")|g" CMakeLists.txt || die

	cmake_src_prepare
}

src_configure() {
	setup-wxwidgets

	local mycmakeargs=(
		-DCMAKE_BUILD_TYPE=Release
		-DCMAKE_INSTALL_DO_STRIP=OFF
		-DCOPY_WX_LIBS=OFF
		-DUSE_PCH=OFF
		-DWITH_POSTGRES=$(usex postgres ON OFF)
	)

	if use mariadb || use mysql; then
		mycmakeargs+=( -DWITH_MYSQL=ON )
	else
		mycmakeargs+=( -DWITH_MYSQL=OFF )
	fi

	cmake_src_configure
}

src_install() {
	cmake_src_install
	domenu "${FILESDIR}/codelite.desktop"

	# Somehow the build system forgets to install the bundled yaml-cpp
	exeinto "/usr/$(get_libdir)/codelite"
	doexe "${BUILD_DIR}"/lib/libyaml-cpp.so*
}
