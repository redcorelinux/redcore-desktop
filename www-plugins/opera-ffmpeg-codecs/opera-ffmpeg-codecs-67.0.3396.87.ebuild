# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit eutils rpm

DESCRIPTION="Additional proprietary codecs for opera"
HOMEPAGE="http://ffmpeg.org/"
SRC_URI="http://mirror.yandex.ru/fedora/russianfedora/russianfedora/nonfree/fedora/updates/27/x86_64/opera-stable-libffmpeg-${PV}-1.fc27.R.x86_64.rpm"

LICENSE="LGPL2.1"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND=""
RDEPEND="www-client/opera"

RESTRICT="mirror strip"

S="${WORKDIR}"

src_unpack() {
	rpm_src_unpack ${A}
}

src_prepare() {
	:
}

src_compile() {
	:
}

src_install() {
	dodir usr/$(get_libdir)/opera/lib_extra
	insinto usr/$(get_libdir)/opera/lib_extra
	doins ${S}/usr/lib64/opera-stable/lib_extra/libffmpeg.so
}
