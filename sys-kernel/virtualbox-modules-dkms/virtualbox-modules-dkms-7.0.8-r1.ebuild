# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=7

inherit eutils

MY_P="vbox-kernel-module-src-${PV}"
DESCRIPTION="Kernel Modules source for Virtualbox"
HOMEPAGE="http://www.virtualbox.org/"
SRC_URI="https://dev.gentoo.org/~ceamac/app-emulation/virtualbox-modules/${MY_P}.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64"
RESTRICT="mirror"
IUSE=""

DEPEND="
	sys-apps/ethtool
	sys-kernel/dkms
"
RDEPEND="${DEPEND}"

PATCHES=( ${FILESDIR}/Makefile-dkms.patch )

S=${WORKDIR}

src_prepare() {
	default
	grep -lR linux/autoconf.h *  | xargs sed -i -e 's:<linux/autoconf.h>:<generated/autoconf.h>:'
}

src_compile() {
	:
}

src_install() {
	dodir usr/src/${P}
	insinto usr/src/${P}
	doins ${FILESDIR}/dkms.conf
	doins -r ${S}/*
}

pkg_postinst() {
	dkms add ${PN}/${PV}
}

pkg_prerm() {
	dkms remove ${PN}/${PV} --all
}
