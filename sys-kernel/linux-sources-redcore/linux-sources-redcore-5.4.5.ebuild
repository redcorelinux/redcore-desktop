# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils

EXTRAVERSION="redcore"
KV_FULL="${PV}-${EXTRAVERSION}"
KV_MAJOR="5.4"

DESCRIPTION="Official Redcore Linux Kernel Sources"
HOMEPAGE="https://redcorelinux.org"
SRC_URI="https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-${PV}.tar.xz"

KEYWORDS="amd64"
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
	"${FILESDIR}"/"${KV_MAJOR}"-0001-linux-hardened.patch
	"${FILESDIR}"/"${KV_MAJOR}"-0001-uksm-linux-hardened.patch
	"${FILESDIR}"/"${KV_MAJOR}"-0001-MultiQueue-Skiplist-Scheduler-v0.196-linux-hardened.patch
	"${FILESDIR}"/"${KV_MAJOR}"-0002-Make-preemptible-kernel-default.patch
	"${FILESDIR}"/"${KV_MAJOR}"-0003-Expose-vmsplit-for-our-poor-32-bit-users.patch
	"${FILESDIR}"/"${KV_MAJOR}"-0004-Create-highres-timeout-variants-of-schedule_timeout-.patch
	"${FILESDIR}"/"${KV_MAJOR}"-0005-Special-case-calls-of-schedule_timeout-1-to-use-the-.patch
	"${FILESDIR}"/"${KV_MAJOR}"-0006-Convert-msleep-to-use-hrtimers-when-active.patch
	"${FILESDIR}"/"${KV_MAJOR}"-0007-Replace-all-schedule-timeout-1-with-schedule_min_hrt.patch
	"${FILESDIR}"/"${KV_MAJOR}"-0008-Replace-all-calls-to-schedule_timeout_interruptible-.patch
	"${FILESDIR}"/"${KV_MAJOR}"-0009-Replace-all-calls-to-schedule_timeout_uninterruptibl.patch
	"${FILESDIR}"/"${KV_MAJOR}"-0010-Don-t-use-hrtimer-overlay-when-pm_freezing-since-som.patch
	"${FILESDIR}"/"${KV_MAJOR}"-0011-Make-threaded-IRQs-optionally-the-default-which-can-.patch
	"${FILESDIR}"/"${KV_MAJOR}"-0012-Reinstate-default-Hz-of-100-in-combination-with-MuQS.patch
	"${FILESDIR}"/"${KV_MAJOR}"-0013-Swap-sucks.patch
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
