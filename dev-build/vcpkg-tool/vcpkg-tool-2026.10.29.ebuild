# Copyright 2026 Redcore Linux Project
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

MY_PV="${PV//./-}"

DESCRIPTION="Library manager for C/C++ (tool only)"
HOMEPAGE="https://github.com/microsoft/vcpkg-tool https://vcpkg.io/en/index.html"
SRC_URI="https://github.com/microsoft/${PN}/archive/refs/tags/${MY_PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

IUSE="test"
RESTRICT="!test? ( test )"

DEPEND="
	dev-libs/libfmt:=
	net-misc/curl"

RDEPEND="
	${DEPEND}
	app-arch/zip"

BDEPEND="
	dev-util/cmakerc"

S="${WORKDIR}/${PN}-${MY_PV}"

src_prepare() {
	find azure-pipelines/e2e-ports -name CMakeLists.txt \
		-exec sed -i -e 's/cmake_minimum_required(VERSION 3\.7\.2)/cmake_minimum_required(VERSION 3.10)/' {} + || die

	cmake_src_prepare
}

src_configure() {
	local preset value
	local mycmakeargs=(
		"-DBUILD_TESTING=$(usex test)"
		-DCMAKE_POLICY_VERSION_MINIMUM=3.5
		-DBUILD_SHARED_LIBS=OFF
		-DVCPKG_BUILD_TLS12_DOWNLOADER=OFF
		-DVCPKG_DEPENDENCY_CMAKERC=ON
		-DVCPKG_DEPENDENCY_EXTERNAL_FMT=ON
		-DVCPKG_LIBCURL_DLSYM=OFF
		-DVCPKG_DEVELOPMENT_WARNINGS=OFF
		-DVCPKG_EMBED_GIT_SHA=OFF
		-DVCPKG_OFFICIAL_BUILD=ON
		-DVCPKG_WARNINGS_AS_ERRORS=OFF
		-DCMAKE_DISABLE_PRECOMPILE_HEADERS=OFF
	)

	for preset in VCPKG_ARTIFACTS_SHA VCPKG_BASE_VERSION VCPKG_STANDALONE_BUNDLE_SHA; do
		value=$(awk -F '"' -v key="${preset}" '$2 == key { print $4; exit }' \
			CMakePresets.json) || die
		[[ -n ${value} ]] || die "missing ${preset} in CMakePresets.json"
		mycmakeargs+=( "-D${preset}=${value}" )
	done

	cmake_src_configure
}

src_install() {
	cmake_src_install

	newenvd - 99vcpkg <<-EOF
		VCPKG_FORCE_SYSTEM_BINARIES="1"
		VCPKG_SYSTEM_BINARY="${EPREFIX}/usr/bin/vcpkg"
	EOF
}
