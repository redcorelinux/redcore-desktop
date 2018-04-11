# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils

EXTRAVERSION="redcore"
KV_FULL="${PV}-${EXTRAVERSION}"

DESCRIPTION="Official Redcore Linux Kernel Sources"
HOMEPAGE="https://redcorelinux.org"
SRC_URI="https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-${PV}.tar.xz"

KEYWORDS="~amd64"
LICENSE="GPL-2"
SLOT="${PV}"
IUSE=""

RESTRICT="strip mirror"
DEPEND="
	app-arch/xz-utils
	sys-devel/autoconf
	sys-devel/bc
	sys-devel/make"
RDEPEND="${DEPEND}"

PATCHES=( "${FILESDIR}"/enable_alx_wol.patch
	"${FILESDIR}"/0001-Revert-ath10k-activate-user-space-firmware-loading-a.patch
	"${FILESDIR}"/0001-Revert-swiotlb-remove-various-exports.patch
	"${FILESDIR}"/0001-Revert-x86-ACPI-cstate-Allow-ACPI-C1-FFH-MWAIT-use-o.patch
	"${FILESDIR}"/mute-pps_state_mismatch.patch
	"${FILESDIR}"/drop_ancient-and-wrong-msg.patch
	"${FILESDIR}"/nouveau-pascal-backlight.patch
	"${FILESDIR}"/linux-hardened.patch
	"${FILESDIR}"/uksm-for-linux-hardened.patch )

S="${WORKDIR}"/linux-"${PV}"

pkg_setup() {
	export REAL_ARCH="$ARCH"
	unset ARCH ; unset LDFLAGS #will interfere with Makefile if set
}

src_prepare() {
	default
	emake mrproper
	sed -ri "s|^(EXTRAVERSION =).*|\1 -${EXTRAVERSION}|" Makefile
	cp "${FILESDIR}"/"${EXTRAVERSION}"-amd64.config .config
}

src_compile() {
	emake prepare modules_prepare
}

src_install() {
	dodir usr/src/linux-"${KV_FULL}"
	cp -ax "${S}"/* "${D}"usr/src/linux-"${KV_FULL}"
}

_kernel_sources_delete() {
	rm -rf "${ROOT}"usr/src/linux-"${KV_FULL}"
}

pkg_postrm() {
	_kernel_sources_delete
}
