# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils

EXTRAVERSION="redcore-lts"
KV_FULL="${PV}-${EXTRAVERSION}"

DESCRIPTION="Official Redcore Linux LTS Kernel Sources"
HOMEPAGE="https://gitlab.com/redcore/kernel"
SRC_URI="https://github.com/redcorelinux/kernel/archive/linux-${KV_FULL}.tar.gz"

KEYWORDS="~amd64"
LICENSE="GPL-2"
SLOT="${PV}"
IUSE=""

RESTRICT="strip mirror"
DEPEND="
	app-arch/xz-utils
	sys-devel/autoconf
	sys-devel/bc
	sys-devel/make"
RDEPEND="${DEPEND}"

S="$WORKDIR/kernel-linux-${KV_FULL}"

pkg_setup() {
	export REAL_ARCH="$ARCH"
	unset ARCH ; unset LDFLAGS #will interfere with Makefile if set
}

src_prepare() {
	default
	emake mrproper
	sed -ri "s|^(EXTRAVERSION =).*|\1 -${EXTRAVERSION}|" Makefile
	cp "redcore/config/"${EXTRAVERSION}"-4.14-amd64.config" .config
}

src_compile() {
	emake prepare modules_prepare
}

src_install() {
	dodir usr/src/linux-"${KV_FULL}"
	cp -ax "${S}"/* "${D}"usr/src/linux-"${KV_FULL}"
}
