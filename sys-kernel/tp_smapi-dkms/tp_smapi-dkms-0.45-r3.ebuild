# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PN=tp_smapi
MY_P=${MY_PN}-${PV}
DESCRIPTION="IBM ThinkPad SMAPI BIOS driver sources"
HOMEPAGE="https://github.com/linux-thinkpad/tp_smapi"
SRC_URI="https://github.com/linux-thinkpad/tp_smapi/releases/download/tp-smapi/${PV}/${MY_P}.tgz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"

IUSE="hdaps"

DEPEND="sys-kernel/dkms"
RDEPEND="${DEPEND}"

S=${WORKDIR}/${MY_P}

pkg_setup() {
	if use hdaps; then
		local CONFIG_CHECK="~INPUT_UINPUT"
		local WARNING_INPUT_UINPUT="Your kernel needs uinput for the hdaps module to perform better"
		local CONFIG_CHECK="~!SENSORS_HDAPS"
		local ERROR_SENSORS_HDAPS="${P} with USE=hdaps conflicts with in-kernel HDAPS (CONFIG_SENSORS_HDAPS)"
	fi
}

src_compile() {
	:
}

src_install() {
	if use hdaps; then
		cp "${FILESDIR}"/dkms-hdaps.conf "${S}"/dkms.conf || die
	else
		cp "${FILESDIR}"/dkms.conf "${S}" || die
	fi
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
