# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=8

inherit udev

DESCRIPTION="Kernel Modules (guest) for Virtualbox"
HOMEPAGE="http://www.virtualbox.org/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64"
IUSE=""

DEPEND="
	acct-group/vboxguest
	acct-group/vboxsf
	acct-user/vboxguest
	~sys-kernel/${PN}-dkms-${PV}"
RDEPEND="${DEPEND}"

S=${WORKDIR}

src_compile() {
	:
}

src_install() {
	insinto /etc/modprobe.d/
	newins "${FILESDIR}"/virtualbox-guest-kmod virtualbox-guest.conf

	insinto /lib/udev/rules.d
	newins "${FILESDIR}"/virtualbox-guest-rules 60-virtualbox-guest-additions.rules
}

pkg_postinst() {
	udev_reload
}

pkg_postrm() {
	udev_reload
}
