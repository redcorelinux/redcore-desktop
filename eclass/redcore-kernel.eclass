# Copyright 2026 Redcore Linux Project
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: redcore-kernel.eclass
# @MAINTAINER:
# Redcore Linux Project <contact@redcorelinux.org>
# @AUTHOR:
# Redcore Linux Project <contact@redcorelinux.org>
# @SUPPORTED_EAPIS: 8
# @BLURB: Unified eclass for building and installing Redcore Linux mainline and LTS kernel images and sources.
# @DESCRIPTION:
# This eclass standardizes the build process, source installation, configuration handling, 
# and post-installation hooks (such as GRUB updates, Dracut initrd generation, and DKMS module 
# management) across all Redcore Linux kernel image and source packages (mainline and LTS variants).

case ${EAPI} in
	8) ;;
	*) die "${ECLASS}: EAPI ${EAPI:-0} not supported" ;;
esac

if [[ -z ${_REDCORE_KERNEL_ECLASS} ]]; then
_REDCORE_KERNEL_ECLASS=1

case ${PN} in
	linux-image-redcore)
		REDCORE_KERNEL_TYPE="image"
		: "${EXTRAVERSION:=redcore-${PR}}"
		DESCRIPTION="Redcore Linux Kernel Image"
		;;
	linux-image-redcore-lts)
		REDCORE_KERNEL_TYPE="image"
		: "${EXTRAVERSION:=redcore-lts-${PR}}"
		DESCRIPTION="Redcore Linux LTS Kernel Image"
		;;
	linux-sources-redcore)
		REDCORE_KERNEL_TYPE="sources"
		: "${EXTRAVERSION:=redcore-${PR}}"
		DESCRIPTION="Redcore Linux Kernel Sources"
		;;
	linux-sources-redcore-lts)
		REDCORE_KERNEL_TYPE="sources"
		: "${EXTRAVERSION:=redcore-lts-${PR}}"
		DESCRIPTION="Redcore Linux LTS Kernel Sources"
		;;
	*)
		die "${ECLASS}: Unsupported package '${PN}'"
		;;
esac

: "${KV_MAJOR:=$(ver_cut 1-2)}"
: "${KV_FULL:=${PV}-${EXTRAVERSION}}"
: "${KERNEL_CONFIG:=${FILESDIR}/${KV_MAJOR}-amd64.config}"
: "${KERNEL_SOURCES_PKG:=sys-kernel/${PN/image/sources}}"

HOMEPAGE="https://redcorelinux.org"
SRC_URI="https://cdn.kernel.org/pub/linux/kernel/v$(ver_cut 1).x/linux-${PV}.tar.xz"

LICENSE="GPL-2"
SLOT="${KV_MAJOR}"

COMMON_DEPEND="
	app-arch/lz4
	app-arch/xz-utils
	dev-build/autoconf
	dev-build/make
	sys-devel/bc"

if [[ ${REDCORE_KERNEL_TYPE} == "image" ]]; then
	IUSE="+cryptsetup +dmraid +dracut +dkms live +mdadm"
	RESTRICT="binchecks strip mirror"
	DEPEND="${COMMON_DEPEND}
		cryptsetup? ( sys-fs/cryptsetup )
		dmraid? ( sys-fs/dmraid )
		dracut? ( >=sys-kernel/dracut-0.44-r8 )
		dkms? ( sys-kernel/dkms ${KERNEL_SOURCES_PKG}:${SLOT} )
		mdadm? ( sys-fs/mdadm )
		>=sys-kernel/linux-firmware-20180314"
else
	IUSE=""
	RESTRICT="strip mirror"
	DEPEND="${COMMON_DEPEND}"
fi

RDEPEND="${DEPEND}"
S="${WORKDIR}/linux-${PV}"

_grub2_update_grubcfg() {
	if [[ -x $(which grub2-mkconfig) ]]; then
		elog "Updating GRUB-2 bootloader configuration, please wait"
		grub2-mkconfig -o "${ROOT}"/boot/grub/grub.cfg
	else
		elog "It looks like you're not using GRUB-2, you must update bootloader configuration manually"
	fi
}

_dracut_initrd_create() {
	if [[ -x $(which dracut) ]]; then
		elog "Generating initrd for ${KV_FULL}, please wait"
		addpredict /etc/ld.so.cache~
		dracut -N -f --kver="${KV_FULL}" "${ROOT}"/boot/initrd-"${KV_FULL}"
	else
		elog "It looks like you're not using dracut, you must generate an initrd manually"
	fi
}

_dracut_initrd_cleanup() {
	rm -rf "${ROOT}"/boot/initrd-"${KV_FULL}"
}

_dkms_modules_install() {
	if [[ -x $(which dkms) ]] ; then
		export local DKMSMOD
		for DKMSMOD in $(dkms status | cut -d " " -f1,2 | sed -e 's/,//g' | sed -e 's/ /\//g' | sed -e 's/://g' | uniq) ; do
			dkms install "${DKMSMOD}" -k "${KV_FULL}"
		done
	fi
}

_dkms_modules_cleanup() {
	if [[ -x $(which dkms) ]] ; then
		export local DKMSMOD
		for DKMSMOD in $(dkms status | cut -d " " -f1,2 | sed -e 's/,//g' | sed -e 's/ /\//g' | sed -e 's/://g' | uniq) ; do
			dkms remove "${DKMSMOD}" -k "${KV_FULL}"
			dkms add "${DKMSMOD}" > /dev/null 2>&1
		done
	fi
}

_kernel_modules_cleanup() {
	rm -rf "${ROOT}"/lib/modules/"${KV_FULL}"
}

_kernel_sources_cleanup() {
	rm -rf "${ROOT}"/usr/src/linux-"${KV_FULL}"
}

redcore-kernel_pkg_setup() {
	export KBUILD_BUILD_USER="nexus"
	export KBUILD_BUILD_HOST="nexus.redcorelinux.org"

	export REAL_ARCH="$ARCH"
	unset ARCH ; unset LDFLAGS #will interfere with Makefile if set
}

redcore-kernel_src_prepare() {
	default
	emake mrproper
	sed -ri "s|^(EXTRAVERSION =).*|\1 -${EXTRAVERSION}|" Makefile
	cp "${KERNEL_CONFIG}" .config
	rm -rf $(find . -type f|grep -F \.orig)
}

redcore-kernel_src_compile() {
	if [[ ${REDCORE_KERNEL_TYPE} == "image" ]]; then
		emake prepare modules_prepare bzImage modules
	else
		emake prepare modules_prepare
	fi
}

redcore-kernel_src_install() {
	if [[ ${REDCORE_KERNEL_TYPE} == "image" ]]; then
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

		rm -f "${D}"/lib/modules/"${KV_FULL}"/build
		rm -f "${D}"/lib/modules/"${KV_FULL}"/source
		export local KSYMS
		for KSYMS in build source ; do
			dosym ../../../usr/src/linux-"${KV_FULL}" lib/modules/"${KV_FULL}"/"${KSYMS}"
		done
		if use live ; then
			insinto /etc/calamares/modules
			doins "${FILESDIR}"/bootloader.conf
			doins "${FILESDIR}"/dracut.conf
			sed -i 's|REDCORE_KERNEL_VERSION|'"${KV_FULL}"'|g' "${D}/etc/calamares/modules/bootloader.conf" || die
			sed -i 's|REDCORE_KERNEL_VERSION|'"${KV_FULL}"'|g' "${D}/etc/calamares/modules/dracut.conf" || die
		fi
	else
		dodir usr/src/linux-"${KV_FULL}"
		cp -ax "${S}"/* "${D}"/usr/src/linux-"${KV_FULL}"
		insinto usr/src/linux-"${KV_FULL}"
		newins "${KERNEL_CONFIG}" .config
	fi
}

redcore-kernel_pkg_postinst() {
	if [[ ${REDCORE_KERNEL_TYPE} == "image" ]]; then
		if [ $(stat -c %d:%i /) == $(stat -c %d:%i /proc/1/root/.) ]; then
			if use dkms; then
				_dkms_modules_install
			fi
			if use dracut; then
				_dracut_initrd_create
			fi
			_grub2_update_grubcfg
		fi
	fi
}

redcore-kernel_pkg_postrm() {
	if [[ ${REDCORE_KERNEL_TYPE} == "image" ]]; then
		if [ $(stat -c %d:%i /) == $(stat -c %d:%i /proc/1/root/.) ]; then
			if use dkms; then
				_dkms_modules_cleanup
			fi
			if use dracut; then
				_dracut_initrd_cleanup
			fi
			_grub2_update_grubcfg
		fi
		_kernel_modules_cleanup
	else
		_kernel_sources_cleanup
	fi
}

if [[ ${REDCORE_KERNEL_TYPE} == "image" ]]; then
	EXPORT_FUNCTIONS pkg_setup src_prepare src_compile src_install pkg_postinst pkg_postrm
else
	EXPORT_FUNCTIONS pkg_setup src_prepare src_compile src_install pkg_postrm
fi

fi
