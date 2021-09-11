# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils

EXTRAVERSION="redcore"
KV_FULL="${PV}-${EXTRAVERSION}"
KV_MAJOR="5.14"

DESCRIPTION="Redcore Linux Kernel Sources"
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
	"${FILESDIR}"/"${KV_MAJOR}"-ath10k-be-quiet.patch
	"${FILESDIR}"/"${KV_MAJOR}"-ata-fix-NCQ-LOG-strings-and-move-to-debug.patch
	"${FILESDIR}"/"${KV_MAJOR}"-radeon_dp_aux_transfer_native-no-ratelimited_debug.patch
	"${FILESDIR}"/"${KV_MAJOR}"-acpi-use-kern_warning_even_when_error.patch
	"${FILESDIR}"/"${KV_MAJOR}"-nvme-Patriot_Viper_VPN100-QUIRK_IGNORE_DEV_SUBNQN.patch
	"${FILESDIR}"/"${KV_MAJOR}"-do_not_bug_the_next_18-years.patch
	"${FILESDIR}"/"${KV_MAJOR}"-iwlwifi-use-debug-for-debug-infos.patch
	"${FILESDIR}"/"${KV_MAJOR}"-fix-bootconfig-makefile.patch
	"${FILESDIR}"/"${KV_MAJOR}"-apic_vector-spam-in-debug-mode-only.patch
	"${FILESDIR}"/"${KV_MAJOR}"-iwlwifi-fix-5e003982b07ae.patch
	"${FILESDIR}"/"${KV_MAJOR}"-0001-Revert-cpufreq-Avoid-configuring-old-governors-as-de.patch
	"${FILESDIR}"/"${KV_MAJOR}"-revert-parts-of-a00ec3874e7d326ab2dffbed92faddf6a77a84e9-no-Intel-NO.patch
	"${FILESDIR}"/"${KV_MAJOR}"-k10temp-frugalware.patch
	"${FILESDIR}"/"${KV_MAJOR}"-fix-bootconfig.patch
	"${FILESDIR}"/"${KV_MAJOR}"-ZEN-Add-sysctl-and-CONFIG-to-disallow-unprivileged-C.patch
	"${FILESDIR}"/"${KV_MAJOR}"-uksm.patch
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
