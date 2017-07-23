# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

MULTILIB_COMPAT=( abi_x86_{32,64} )

PRINTER_MODEL=( "ix6700" "ix6800" "ip2800" "mx470" "mx530" "ip8700" "e560" "e400" )
PRINTER_ID=( "431" "432" "433" "434" "435" "436" "437" "438" )

inherit ecnij

DESCRIPTION="Canon InkJet Printer Driver for Linux (Pixus/Pixma-Series)"
HOMEPAGE="http://www.canon-europe.com/Support/"
SRC_URI="http://gdlp01.c-wss.com/gds/8/0100005858/01/${PN}-source-${PV}-1.tar.gz"

IUSE="+doc"

DEPEND="virtual/libusb:1"
RDEPEND="${RDEPEND}"

RESTRICT="mirror"

PATCHES=(
	"${FILESDIR}"/${PN}-3.70-1-libexec-cups.patch
	"${FILESDIR}"/${PN}-3.70-1-libexec-backend.patch
	"${FILESDIR}"/${PN}-4.00-1-libexec-backend.patch
	"${FILESDIR}"/${PN}-4.00-1-libexec-cups.patch
	"${FILESDIR}"/${PN}-4.00-4-ppd.patch
	"${FILESDIR}"/${PN}-4.00-5-abi_x86_32.patch
	"${FILESDIR}"/${PN}-3.80-1-cups-1.6.patch
	"${FILESDIR}"/${PN}-3.90-6-headers.patch
	"${FILESDIR}"/${PN}-3.80-6-cups-1.6.patch
	"${FILESDIR}"/${PN}-4.00-6-headers.patch
)

src_prepare() {
	local arc=64
	[[ x${ABI} == xx86 ]] && arc=32
	sed -e "s,cnijlgmon2_LDADD =,cnijlgmon2_LDADD = -L../../com/libs_bin${arc}," \
		-i lgmon2/src/Makefile.am || die

	ecnij_src_prepare
}

src_install() {
	ecnij_src_install

	# dirty hack to stop cnijfilter spamming ldconfig
	for i in libcnbpcmcm43{1..8}.so; do
		rm -rf ${ED}usr/lib32/${i}
		ln -sf ${ED}usr/lib32/${i}.8.20.1 ${ED}usr/lib32/${i}
	done
	for i in libcnbpcnclapi43{1..8}.so; do
		rm -rf ${ED}usr/lib32/${i}
		ln -sf ${ED}usr/lib32/${i}.4.1.0 ${ED}usr/lib32/${i}
	done
	for i in libcnbpcnclbjcmd43{1..8}.so; do
		rm -rf ${ED}usr/lib32/${i}
		ln -sf ${ED}usr/lib32/${i}.3.3.0 ${ED}usr/lib32/${i}
	done
	for i in libcnbpcnclui43{1..8}.so; do
		rm -rf ${ED}usr/lib32/${i}
		ln -sf ${ED}usr/lib32/${i}.4.1.0 ${ED}usr/lib32/${i}
	done
	for i in libcnbpess43{1..8}.so; do
		rm -rf ${ED}usr/lib32/${i}
		ln -sf ${ED}usr/lib32/${i}.4.3.1 ${ED}usr/lib32/${i}
	done
	for i in libcnbpo43{1,2}.so; do
		rm -rf ${ED}usr/lib32/${i}
		ln -sf ${ED}usr/lib32/${i}.1.0.3 ${ED}usr/lib32/${i}
	done
	for i in libcnbpo43{3,6,8}.so; do
		rm -rf ${ED}usr/lib32/${i}
		ln -sf ${ED}usr/lib32/${i}.1.0.1 ${ED}usr/lib32/${i}
	done
	for i in libcnbpo43{4,5,7}.so; do
		rm -rf ${ED}usr/lib32/${i}
		ln -sf ${ED}usr/lib32/${i}.1.0.4 ${ED}usr/lib32/${i}
	done
}
