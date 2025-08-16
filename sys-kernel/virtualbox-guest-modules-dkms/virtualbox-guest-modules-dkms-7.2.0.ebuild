# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=8


MY_PN="VirtualBox"
MY_PV=${PV^^}
MY_P=${MY_PN}-${MY_PV}

DESCRIPTION="Kernel Modules (guest) source for Virtualbox"
HOMEPAGE="http://www.virtualbox.org/"
SRC_URI="https://download.virtualbox.org/virtualbox/${MY_PV}/${MY_P}.tar.bz2"
S="${WORKDIR}/${MY_PN}-${MY_PV}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="mirror"
IUSE=""

DEPEND="
	sys-kernel/dkms
"
RDEPEND="
	${DEPEND}
"
BDEPEND="
	>=dev-build/kbuild-0.1.9998.3660
"

VBOX_MOD_SRC_DIR="out/linux.${ARCH}/release/bin/additions/src"

src_prepare() {
	rm -r kBuild/bin tools || die

	pushd src/VBox/Additions &>/dev/null || die
	ebegin "Extracting guest kernel module sources"
	kmk GuestDrivers-src vboxguest-src vboxsf-src &>/dev/null
	eend $? || die
	popd &>/dev/null || die

	eapply -d "${VBOX_MOD_SRC_DIR}" -- "${FILESDIR}"/vboxguest-6.1.36-log-use-c99.patch
	eapply -d "${VBOX_MOD_SRC_DIR}" -- "${FILESDIR}"/Makefile-no-vboxvideo.patch
	eapply -d "${VBOX_MOD_SRC_DIR}" -- "${FILESDIR}"/Makefile-dkms.patch

	eapply_user
}

src_configure() {
	:
}

src_compile() {
	:
}

src_install() {
	dodir usr/src/${P}
	insinto usr/src/${P}
	doins ${FILESDIR}/dkms.conf
	doins -r ${VBOX_MOD_SRC_DIR}/*
}

pkg_postinst() {
	dkms add ${PN}/${PV}
}

pkg_prerm() {
	dkms remove ${PN}/${PV} --all
}
