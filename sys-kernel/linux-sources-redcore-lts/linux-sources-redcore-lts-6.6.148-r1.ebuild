# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

EXTRAVERSION="redcore-lts-${PR}"
KV_FULL="${PV}-${EXTRAVERSION}"
KV_MAJOR="6.6"

DESCRIPTION="Redcore Linux LTS Kernel Sources"
HOMEPAGE="https://redcorelinux.org"
SRC_URI="https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-${PV}.tar.xz"

KEYWORDS="~amd64"
LICENSE="GPL-2"
SLOT="${KV_MAJOR}"
IUSE=""

RESTRICT="strip mirror"
DEPEND="
	app-arch/lz4
	app-arch/xz-utils
	dev-build/autoconf
	dev-build/make
	sys-devel/bc"
RDEPEND="${DEPEND}"

PATCHES=(
	"${FILESDIR}"/"${KV_MAJOR}"-ath10k-be-quiet.patch
	"${FILESDIR}"/"${KV_MAJOR}"-ata-fix-NCQ-LOG-strings-and-move-to-debug.patch
	"${FILESDIR}"/"${KV_MAJOR}"-acpi-use-kern_warning_even_when_error.patch
	"${FILESDIR}"/"${KV_MAJOR}"-fix-bootconfig-makefile.patch
	"${FILESDIR}"/"${KV_MAJOR}"-apic_vector-spam-in-debug-mode-only.patch
	"${FILESDIR}"/"${KV_MAJOR}"-0001-Revert-cpufreq-Avoid-configuring-old-governors-as-de.patch
	"${FILESDIR}"/"${KV_MAJOR}"-revert-parts-of-a00ec3874e7d326ab2dffbed92faddf6a77a84e9-no-Intel-NO.patch
	"${FILESDIR}"/"${KV_MAJOR}"-ZEN-Add-sysctl-and-CONFIG-to-disallow-unprivileged-C.patch
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
	cp -ax "${S}"/* "${D}"/usr/src/linux-"${KV_FULL}"
	insinto usr/src/linux-"${KV_FULL}"
	newins "${FILESDIR}"/"${KV_MAJOR}"-amd64.config .config
}

_kernel_sources_delete() {
	rm -rf "${ROOT}"/usr/src/linux-"${KV_FULL}"
}

pkg_postrm() {
	_kernel_sources_delete
}
