# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils

EXTRAVERSION="redcore-lts"
KV_FULL="${PV}-${EXTRAVERSION}"

DESCRIPTION="Official Redcore Linux Kernel Sources"
HOMEPAGE="https://redcorelinux.org"
SRC_URI="https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-${PV}.tar.xz"

KEYWORDS="amd64"
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

PATCHES=( "${FILESDIR}"/introduce-NUMA-identity-node-sched-domain.patch
	"${FILESDIR}"/k10temp-add-ZEN-support.patch
	"${FILESDIR}"/mute-pps_state_mismatch.patch
	"${FILESDIR}"/restore-SD_PREFER_SIBLING-on-MC-domains.patch
	"${FILESDIR}"/Revert-ath10k-activate-user-space-firmware-loading.patch
	"${FILESDIR}"/linux-hardened.patch
	"${FILESDIR}"/uksm-linux-hardened.patch
	"${FILESDIR}"/0001-MuQSS-version-0.162-CPU-scheduler-linux-hardened.patch
	"${FILESDIR}"/0002-Make-preemptible-kernel-default.patch
	"${FILESDIR}"/0003-Expose-vmsplit-for-our-poor-32-bit-users.patch
	"${FILESDIR}"/0004-Create-highres-timeout-variants-of-schedule_timeout-.patch
	"${FILESDIR}"/0005-Special-case-calls-of-schedule_timeout-1-to-use-the-.patch
	"${FILESDIR}"/0006-Convert-msleep-to-use-hrtimers-when-active.patch
	"${FILESDIR}"/0007-Replace-all-schedule-timeout-1-with-schedule_min_hrt.patch
	"${FILESDIR}"/0008-Replace-all-calls-to-schedule_timeout_interruptible-.patch
	"${FILESDIR}"/0009-Replace-all-calls-to-schedule_timeout_uninterruptibl.patch
	"${FILESDIR}"/0010-Don-t-use-hrtimer-overlay-when-pm_freezing-since-som.patch
	"${FILESDIR}"/0011-Make-hrtimer-granularity-and-minimum-hrtimeout-confi.patch
	"${FILESDIR}"/0012-Reinstate-default-Hz-of-100-in-combination-with-MuQS.patch
	"${FILESDIR}"/0013-Make-threaded-IRQs-optionally-the-default-which-can-.patch
	"${FILESDIR}"/0014-Swap-sucks.patch
	"${FILESDIR}"/0015-MuQSS.c-needs-irq_regs.h-to-use-get_irq_regs.patch
	"${FILESDIR}"/0016-unfuck-MuQSS-on-linux-4_14_15+.patch
	"${FILESDIR}"/0001-BFQ-v8r12-20171108.patch
	"${FILESDIR}"/0002-BFQ-v8r12-20180404.patch )

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
	cp "${FILESDIR}"/"${EXTRAVERSION}"-amd64.config .config
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
