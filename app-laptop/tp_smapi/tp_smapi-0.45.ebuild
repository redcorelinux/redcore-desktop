# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="IBM ThinkPad SMAPI BIOS driver"
HOMEPAGE="https://github.com/linux-thinkpad/tp_smapi"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"

IUSE=""

RDEPEND="
	~sys-kernel/${PN}-dkms-${PV}
	"
DEPEND="${RDEPEND}"

S=${FILESDIR}

src_prepare() {
	default
	:
}

src_compile() {
	:
}

src_install() {
	newinitd "${FILESDIR}/${PN}-0.40-initd" smapi
	newconfd "${FILESDIR}/${PN}-0.40-confd" smapi
}
