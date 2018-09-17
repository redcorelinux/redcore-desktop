# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit flag-o-matic qmake-utils autotools db-use
DESCRIPTION="MEGA C++ SDK"
HOMEPAGE="https://github.com/meganz/sdk"
SRC_URI="https://github.com/meganz/sdk/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD-2"
SLOT="0"
IUSE="freeimage fuse hardened inotify libuv mediainfo +qt +sqlite"

KEYWORDS="~amd64"

DEPEND="
	dev-libs/crypto++
	sys-libs/zlib
	dev-libs/libpcre:3[cxx]
	dev-libs/openssl:0
	net-dns/c-ares
	net-misc/curl
	sqlite? ( dev-db/sqlite:3 )
	!sqlite? ( sys-libs/db:*[cxx] )
	freeimage? ( media-libs/freeimage )
	libuv? ( dev-libs/libuv )
	dev-libs/libsodium
	mediainfo? ( media-libs/libmediainfo )"
RDEPEND="${DEPEND}"

S="${WORKDIR}"/sdk-"${PV}"

pkg_setup() {
	use sqlite || append-cppflags "-I$(db_includedir)"
}

src_prepare() {
	default
	use qt && sed \
		-e '/SOURCES += src\// s:+:-:' \
		-e '/!exists.*config.h/ s:!::' \
		-e 's:-lsqlite3 -lrt:-lmega &:' \
		-i bindings/qt/sdk.pri
	eautoreconf
}

src_configure() {
	local myeconfargs=(
		--enable-chat
		--disable-examples
		$(use_enable inotify)
		$(use_enable hardened gcc-hardening)
		$(use_with libuv)
		$(use_with !sqlite db)
		$(use_with sqlite)
		$(use_with freeimage)
		$(use_with fuse)
		$(use_with mediainfo libmediainfo)
	)
	econf "${myeconfargs[@]}"
}

src_install() {
	default
	doheader -r include/mega

	use qt || return
	insinto /usr/share/${PN}/bindings/qt
	doins bindings/qt/*.{h,cpp,pri}
}
