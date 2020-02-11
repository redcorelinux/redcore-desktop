# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils

EXTRAVERSION="redcore-lts"
KV_FULL="${PV}-${EXTRAVERSION}"
KV_MAJOR="5.4"

DESCRIPTION="Official Redcore Linux Kernel Image"
HOMEPAGE="https://redcorelinux.org"
SRC_URI="https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-${PV}.tar.xz"

KEYWORDS="~amd64"
LICENSE="GPL-2"
SLOT="${PVR}"
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
	dkms? ( sys-kernel/dkms sys-kernel/linux-sources-redcore-lts:${SLOT} )
	mdadm? ( sys-fs/mdadm )
	>=sys-kernel/linux-firmware-20180314"
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
		for DKMSMOD in $(dkms status | cut -d " " -f1,2 | sed -e 's/,//g' | sed -e 's/ /\//g' | sed -e 's/://g' | uniq) ; do
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
