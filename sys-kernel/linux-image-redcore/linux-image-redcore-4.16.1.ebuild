# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils

EXTRAVERSION="redcore"
KV_FULL="${PV}-${EXTRAVERSION}"

DESCRIPTION="Official Redcore Linux Kernel Image"
HOMEPAGE="https://redcorelinux.org"
SRC_URI="https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-${PV}.tar.xz"

KEYWORDS="~amd64"
LICENSE="GPL-2"
SLOT="${PV}"
IUSE="+cryptsetup +dmraid +dracut +dkms +mdadm"

RESTRICT="binchecks strip mirror"
DEPEND="
	app-arch/xz-utils
	sys-devel/autoconf
	sys-devel/bc
	sys-devel/make
	cryptsetup? ( sys-fs/cryptsetup )
	dmraid? ( sys-fs/dmraid )
	dracut? ( sys-kernel/dracut )
	dkms? ( sys-kernel/dkms ~sys-kernel/linux-sources-redcore-${PV} )
	mdadm? ( sys-fs/mdadm )
	>=sys-kernel/linux-firmware-20180314"
RDEPEND="${DEPEND}"

PATCHES=( "${FILESDIR}"/enable_alx_wol.patch
	"${FILESDIR}"/0001-Revert-ath10k-activate-user-space-firmware-loading-a.patch
	"${FILESDIR}"/0001-Revert-swiotlb-remove-various-exports.patch
	"${FILESDIR}"/0001-Revert-x86-ACPI-cstate-Allow-ACPI-C1-FFH-MWAIT-use-o.patch
	"${FILESDIR}"/0001-Make-it-possible-to-disable-SWIOTLB-code-on-admgpu-a.patch
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
	emake bzImage modules
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
		dracut -f --no-hostonly-cmdline --kver="${KV_FULL}" "${ROOT}"boot/initrd-"${KV_FULL}"
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
	if use dracut; then
		_dracut_initrd_create
	fi
	_grub2_update_grubcfg
}

pkg_postrm() {
	if use dracut; then
		_dracut_initrd_delete
	fi
	if use dkms; then
		_dkms_modules_delete
	fi
	_kernel_modules_delete
	_grub2_update_grubcfg
}
