# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils

EXTRAVERSION="redcore-lts"
KV_FULL="${PV}-${EXTRAVERSION}"

DESCRIPTION="Official Redcore Linux Kernel Image"
HOMEPAGE="https://redcorelinux.org"
SRC_URI="https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-${PV}.tar.xz"

KEYWORDS="amd64"
LICENSE="GPL-2"
SLOT="${PV}"
IUSE="+cryptsetup +dmraid +dracut +dkms +mdadm"

RESTRICT="binchecks strip mirror"
DEPEND="
	app-arch/lz4
	app-arch/xz-utils
	sys-devel/autoconf
	sys-devel/bc
	sys-devel/make
	cryptsetup? ( sys-fs/cryptsetup )
	dmraid? ( sys-fs/dmraid )
	dracut? ( >=sys-kernel/dracut-0.44-r8 )
	dkms? ( sys-kernel/dkms ~sys-kernel/linux-sources-redcore-lts-${PV} )
	mdadm? ( sys-fs/mdadm )
	>=sys-kernel/linux-firmware-20180314"
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
	emake prepare modules_prepare bzImage modules
}

src_install() {
	dodir boot
	insinto boot
	newins .config config-"${KV_FULL}"
	newins System.map System.map-"${KV_FULL}"
	newins arch/x86/boot/bzImage vmlinuz-"${KV_FULL}"

	dodir usr/src/linux-"${KV_FULL}"
	insinto usr/src/linux-"${KV_FULL}"
	doins Module.symvers
	doins System.map
	exeinto usr/src/linux-"${KV_FULL}"
	doexe vmlinux

	emake INSTALL_MOD_PATH="${D}" modules_install

	rm -f "${D}"lib/modules/"${KV_FULL}"/build
	rm -f "${D}"lib/modules/"${KV_FULL}"/source
	export local KSYMS
	for KSYMS in build source ; do
		dosym ../../../usr/src/linux-"${KV_FULL}" lib/modules/"${KV_FULL}"/"${KSYMS}"
	done
}

_grub2_update_grubcfg() {
	if [[ -x $(which grub2-mkconfig) ]]; then
		elog "Updating GRUB-2 bootloader configuration, please wait"
		grub2-mkconfig -o "${ROOT}"boot/grub/grub.cfg
	else
		elog "It looks like you're not using GRUB-2, you must update bootloader configuration by hand"
	fi
}

_dracut_initrd_create() {
	if [[ -x $(which dracut) ]]; then
		elog "Generating initrd for "${KV_FULL}", please wait"
		addpredict /etc/ld.so.cache~
		dracut -N -f --kver="${KV_FULL}" "${ROOT}"boot/initrd-"${KV_FULL}"
	else
		elog "It looks like you're not using dracut, you must generate an initrd by hand"
	fi
}

_dracut_initrd_delete() {
	rm -rf "${ROOT}"boot/initrd-"${KV_FULL}"
}

_dkms_modules_delete() {
	if [[ -x $(which dkms) ]] ; then
		export local DKMSMOD
		for DKMSMOD in $(dkms status | cut -d " " -f1,2 | sed -e 's/,//g' | sed -e 's/ /\//g' | sed -e 's/://g') ; do
			dkms remove "${DKMSMOD}" -k "${KV_FULL}"
		done
	fi
}

_kernel_modules_delete() {
	rm -rf "${ROOT}"lib/modules/"${KV_FULL}"
}

pkg_postinst() {
	if [ $(stat -c %d:%i /) == $(stat -c %d:%i /proc/1/root/.) ]; then
		if use dracut; then
			_dracut_initrd_create
		fi
		_grub2_update_grubcfg
	fi
}

pkg_postrm() {
	if [ $(stat -c %d:%i /) == $(stat -c %d:%i /proc/1/root/.) ]; then
		if use dracut; then
			_dracut_initrd_delete
		fi
		_grub2_update_grubcfg
	fi
	if use dkms; then
		_dkms_modules_delete
	fi
	_kernel_modules_delete
}
