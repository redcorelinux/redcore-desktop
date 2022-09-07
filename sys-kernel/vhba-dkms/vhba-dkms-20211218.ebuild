# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit eutils

MY_P=vhba-module-${PV}
DESCRIPTION="Virtual (SCSI) Host Bus Adapter kernel module for the CDEmu suite sources"
HOMEPAGE="http://cdemu.org"
SRC_URI="https://download.sourceforge.net/cdemu/vhba-module/${MY_P}.tar.xz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="amd64 ~hppa x86"
IUSE=""

DEPEND="sys-kernel/dkms"
RDEPEND="${DEPEND}"

S=${WORKDIR}/${MY_P}

src_prepare() {
	default
	sed -e '/ccflags/s/-Werror$/-Wall/' \
		-i Makefile || die "sed failed"
}

src_compile() {
	:
}

src_install() {
	cp "${FILESDIR}/dkms.conf" "${S}" || die
	dodir /usr/src/${P}
	insinto /usr/src/${P}
	doins -r "${S}"/*
}

pkg_postinst() {
	dkms add ${PN}/${PV}
}

pkg_prerm() {
	dkms remove ${PN}/${PV} --all
}

