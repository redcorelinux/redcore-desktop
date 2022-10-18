# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit eutils

DESCRIPTION="Kernel Modules for Virtualbox"
HOMEPAGE="http://www.virtualbox.org/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64"
IUSE=""

DEPEND="
	acct-group/vboxusers
	~sys-kernel/${PN}-dkms-${PV}"
RDEPEND="${DEPEND}"

S=${WORKDIR}

src_compile() {
	:
}

src_install() {
	insinto /etc/modules-load.d/
	insinto /etc/modules-load.d/
	newins "${FILESDIR}"/virtualbox-kmod virtualbox.conf
}
