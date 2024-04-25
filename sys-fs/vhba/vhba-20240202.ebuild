# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit eutils udev

MY_P=vhba-module-${PV}
DESCRIPTION="Virtual (SCSI) Host Bus Adapter kernel module for the CDEmu suite"
HOMEPAGE="http://cdemu.org"
SRC_URI="https://download.sourceforge.net/cdemu/vhba-module/${MY_P}.tar.xz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

RDEPEND="
	~sys-kernel/${PN}-dkms-${PV}
	virtual/udev"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

S=${WORKDIR}/${MY_P}

src_prepare() {
	default
	:
}

src_compile() {
	:
}

src_install() {
	dodoc AUTHORS ChangeLog README

	dodir "$(get_udevdir)"/rules.d
	insinto "$(get_udevdir)"/rules.d
	newins "${FILESDIR}/${PN}"-udev 69-vhba.rules

	dodir /etc/modules-load.d
	insinto /etc/modules-load.d
	newins "${FILESDIR}/${PN}"-kmod vhba.conf
}
