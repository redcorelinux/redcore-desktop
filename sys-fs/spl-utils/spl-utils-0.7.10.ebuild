# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="5"
inherit flag-o-matic autotools-utils

MY_PN="spl"
MY_P="${MY_PN}-${PV}"

SRC_URI="https://github.com/zfsonlinux/zfs/releases/download/zfs-${PV}/${MY_P}.tar.gz"

DESCRIPTION="Userland utilities for SPL Linux kernel module"
HOMEPAGE="http://zfsonlinux.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64"
IUSE="debug"

RESTRICT="debug? ( strip ) test"

S="${WORKDIR}/${MY_P}"

COMMON_DEPEND="dev-lang/perl
	virtual/awk"
DEPEND="${COMMON_DEPEND}"
RDEPEND="${COMMON_DEPEND}
	!sys-devel/spl"

AT_M4DIR="config"
AUTOTOOLS_IN_SOURCE_BUILD="1"

DOCS=( AUTHORS DISCLAIMER )

src_prepare() {
	# Workaround for hard coded path
	sed -i "s|/sbin/lsmod|/bin/lsmod|" "${S}/scripts/check.sh" || \
		die "Cannot patch check.sh"

	# splat is unnecessary unless we are debugging
	use debug || { sed -e 's/^subdir-m += splat$//' -i "${S}/module/Makefile.in" || die ; }

	# Set module revision number
	[ ${PV} != "9999" ] && \
		{ sed -i "s/\(Release:\)\(.*\)1/\1\2${PR}-redcore/" "${S}/META" || die "Could not set Redcore release"; }

	autotools-utils_src_prepare
}

src_configure() {
	filter-ldflags -Wl,*

	local myeconfargs=(
		--bindir="${EPREFIX}/bin"
		--sbindir="${EPREFIX}/sbin"
		--with-config=user
		$(use_enable debug)
	)
	autotools-utils_src_configure
}
