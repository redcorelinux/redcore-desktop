# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils

EXTRAVERSION="redcore-lts"
KV_FULL="${PV}-${EXTRAVERSION}"
KV_MAJOR="5.4"

DESCRIPTION="Official Redcore Linux Kernel Sources"
HOMEPAGE="https://redcorelinux.org"
SRC_URI="https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-${PV}.tar.xz"

KEYWORDS="~amd64"
LICENSE="GPL-2"
SLOT="${PVR}"
IUSE=""

RESTRICT="strip mirror"
DEPEND="
	app-arch/lz4
	app-arch/xz-utils
	sys-devel/autoconf
	sys-devel/bc
	sys-devel/make"
RDEPEND="${DEPEND}"

PATCHES=(
	"${FILESDIR}"/"${KV_MAJOR}"-enable_alx_wol.patch
	"${FILESDIR}"/"${KV_MAJOR}"-drop_ancient-and-wrong-msg.patch
	"${FILESDIR}"/"${KV_MAJOR}"-ata-fix-NCQ-LOG-strings-and-move-to-debug.patch
	"${FILESDIR}"/"${KV_MAJOR}"-radeon_dp_aux_transfer_native-no-ratelimited_debug.patch
	"${FILESDIR}"/"${KV_MAJOR}"-acpi-use-kern_warning_even_when_error.patch
	"${FILESDIR}"/"${KV_MAJOR}"-ath10k-be-quiet.patch
	"${FILESDIR}"/"${KV_MAJOR}"-Unknow-SSD-HFM128GDHTNG-8310B-QUIRK_NO_APST.patch
	"${FILESDIR}"/"${KV_MAJOR}"-nvme-suspend-resume-workaround.patch
	"${FILESDIR}"/"${KV_MAJOR}"-nvme-pci-more-info.patch
	"${FILESDIR}"/"${KV_MAJOR}"-acer-wmi-silence-unknow-functions-messages.patch
	"${FILESDIR}"/"${KV_MAJOR}"-amdgpu-dc_link-drop-some-asserts.patch
	"${FILESDIR}"/"${KV_MAJOR}"-nvme-hwmon.patch
	"${FILESDIR}"/"${KV_MAJOR}"-linux-hardened.patch
	"${FILESDIR}"/"${KV_MAJOR}"-uksm-linux-hardened.patch
)

S="${WORKDIR}"/linux-"${PV}"

pkg_setup() {
	export KBUILD_BUILD_USER="nexus"
	export KBUILD_BUILD_HOST="nexus.redcorelinux.org"

	export REAL_ARCH="$ARCH"
	unset ARCH ; unset LDFLAGS #will interfere with Makefile if set
}

src_prepare() {
	default
	emake mrproper
	sed -ri "s|^(EXTRAVERSION =).*|\1 -${EXTRAVERSION}|" Makefile
	cp "${FILESDIR}"/"${KV_MAJOR}"-amd64.config .config
	rm -rf $(find . -type f|grep -F \.orig)
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
