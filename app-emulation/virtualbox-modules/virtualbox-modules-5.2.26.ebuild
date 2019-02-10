# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit eutils user

DESCRIPTION="Kernel Modules for Virtualbox"
HOMEPAGE="http://www.virtualbox.org/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64"
IUSE=""

DEPEND="~sys-kernel/${PN}-dkms-${PV}"
RDEPEND="${DEPEND}"

S=${WORKDIR}

pkg_setup() {
	enewgroup vboxusers
}

src_compile() {
	:
}

src_install() {
	insinto usr/$(get_libdir)/modules-load.d/
	doins "${FILESDIR}"/virtualbox.conf
}
