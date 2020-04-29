# Copyright 2004-2014 RogentOS Team
# Distributed under the terms of the GNU General Public License v2
# $

# @ECLASS-VARIABLE: K_ROGKERNEL_NAME
# @DESCRIPTION:
# The kernel name used by the ebuild, it should be the ending ${PN} part
# for example, of linux-redcore it is "${PN/${PN/-*}-}" (redcore)
K_ROGKERNEL_NAME="${K_ROGKERNEL_NAME:-${PN/${PN/-*}-}}"

# @ECLASS-VARIABLE: K_ROGKERNEL_SELF_TARBALL_NAME
# @DESCRIPTION:
# If the main kernel sources tarball is generated in-house and available
# on the "redcore" mirror, set this variable to the extension name (see example
# below). This will disable ALL the extra/local patches (since they have to
# be applied inside the tarball). Moreover, K_ROGKERNEL_NAME,
# K_KERNEL_PATCH_VER will be ignored.
# Example:
#   K_ROGKERNEL_SELF_TARBALL_NAME="redcore"
#   This would generate:
#   SRC_URI="mirror://redcore/sys-kernel/linux-${PV}+redcore.tar.${K_TARBALL_EXT}"
K_ROGKERNEL_SELF_TARBALL_NAME="${K_ROGKERNEL_SELF_TARBALL_NAME:-}"

# @ECLASS-VARIABLE: K_ROGKERNEL_PATCH_UPSTREAM_TARBALL
# @DESCRIPTION:
# If set to 1, the ebuild will fetch the upstream kernel tarball and
# apply the RogentOS patch against it. This strategy avoids the need of
# creating complete kernel source tarballs. The default value is 0.
K_ROGKERNEL_PATCH_UPSTREAM_TARBALL="${K_ROGKERNEL_PATCH_UPSTREAM_TARBALL:-0}"

# @ECLASS-VARIABLE: K_ROGKERNEL_FORCE_SUBLEVEL
# @DESCRIPTION:
# Force the rewrite of SUBLEVEL in kernel sources Makefile
K_ROGKERNEL_FORCE_SUBLEVEL="${K_ROGKERNEL_FORCE_SUBLEVEL:-}"

# @ECLASS-VARIABLE: K_KERNEL_NEW_VERSIONING
# @DESCRIPTION:
# Set this to "1" if your kernel ebuild uses the new Linux kernel upstream
# versioning and ${PV} contains the stable revision, like 3.7.1.
# In the example above, this makes the SLOT variable contain only "3.7".
# The sublevel version can be forced using K_ROGKERNEL_FORCE_SUBLEVEL
K_KERNEL_NEW_VERSIONING="${K_KERNEL_NEW_VERSIONING:-1}"

# @ECLASS-VARIABLE: K_KERNEL_IMAGE_NAME
# @DESCRIPTION:
# Set this to a custom kernel image make target if the default does not
# fit your needs. This value if set, is passed to genkernel through the
# --kernel-target= flag.
K_KERNEL_IMAGE_NAME="${K_KERNEL_IMAGE_NAME:-}"

# @ECLASS-VARIABLE: K_ONLY_SOURCES
# @DESCRIPTION:
# For every kernel binary package, there is a kernel source package associated
# if your ebuild is one of them, set this to "1"
K_ONLY_SOURCES="${K_ONLY_SOURCES:-}"

# @ECLASS-VARIABLE: K_REQUIRED_LINUX_FIRMWARE_VER
# @DESCRIPTION:
# Minimum required version of sys-kernel/linux-formware package, if any
K_REQUIRED_LINUX_FIRMWARE_VER="${K_REQUIRED_LINUX_FIRMWARE_VER:-}"

# @ECLASS-VARIABLE: K_GENKERNEL_ARGS
# @DESCRIPTION:
# Provide extra genkernel arguments using K_GENKERNEL_ARGS
K_GENKERNEL_ARGS="${K_GENKERNEL_ARGS:-}"

# @ECLASS-VARIABLE: K_MKIMAGE_RAMDISK_ADDRESS
# @DESCRIPTION:
# [ARM ONLY] Provide the ramdisk load address to be used with mkimage
K_MKIMAGE_RAMDISK_ADDRESS="${K_MKIMAGE_RAMDISK_ADDRESS:-}"

KERN_INITRAMFS_SEARCH_NAME="${KERN_INITRAMFS_SEARCH_NAME:-initramfs-genkernel*${K_ROGKERNEL_NAME}}"

# Disable deblobbing feature
K_DEBLOB_AVAILABLE=0
ETYPE="sources"
K_TARBALL_EXT="${K_TARBALL_EXT:-xz}"

inherit versionator
if [ "${K_KERNEL_NEW_VERSIONING}" = "1" ]; then
	CKV="$(get_version_component_range 1-2)"
fi

inherit eutils multilib kernel-2 redcore-artwork mount-boot linux-info

# from kernel-2 eclass
detect_version
detect_arch

DESCRIPTION="Redcore Linux kernel functions and phases"

## kernel-2 eclass settings
if [ -n "${K_ROGKERNEL_SELF_TARBALL_NAME}" ]; then
	SRC_URI="http://mirror.math.princeton.edu/pub/redcorelinux/distfiles/linux-${PVR}+${K_ROGKERNEL_SELF_TARBALL_NAME}.tar.${K_TARBALL_EXT}"
else
	SRC_URI="${KERNEL_URI}"
fi

_get_real_kv_full() {
	if [[ "${KV_MAJOR}${KV_MINOR}" -eq 26 ]]; then
		echo "${ORIGINAL_KV_FULL}"
	elif [[ "${OKV/.*}" -ge "3" ]]; then
		echo "${ORIGINAL_KV_FULL}"
	else
		echo "${ORIGINAL_KV_FULL}"
	fi
}

# replace "linux" with K_ROGKERNEL_NAME, usually replaces
# "linux" with "redcore" or "server" or "openvz"
EXTRAVERSION="${EXTRAVERSION/${PN/-*}/${K_ROGKERNEL_NAME}}"

if [ "${PR}" == "r0" ] ; then
	KV_FULL="${PV}-${K_ROGKERNEL_NAME}"
	else
	KV_FULL="${PV}-${K_ROGKERNEL_NAME}-${PR}"
fi
ORIGINAL_KV_FULL="${KV_FULL}"

# Starting from linux-3.0, we still have to install
# sources stuff into /usr/src/linux-3.0.0-redcore (example)
# where the last part must always match uname -r
# otherwise kernel-switcher (and RELEASE_LEVEL file)
# will complain badly
KV_OUT_DIR="/usr/src/linux-${KV_FULL}"
S="${WORKDIR}/linux-${KV_FULL}"


if [ "${K_KERNEL_NEW_VERSIONING}" = "1" ]; then
	SLOT="$(get_version_component_range 1-3)"
else
	SLOT="${PV}"
fi

_is_kernel_binary() {
	if [ -z "${K_ONLY_SOURCES}" ]; then
		# yes it is
		return 0
	else
		# no it isn't
		return 1
	fi
}

# provide extra virtual pkg
if _is_kernel_binary; then
	PROVIDE="virtual/linux-binary"
fi

if [ -n "${K_ROGKERNEL_SELF_TARBALL_NAME}" ]; then
	HOMEPAGE="https://gitlab.com/redcore/kernel"
else
	HOMEPAGE="https:/redcorelinux.org"
fi

# Returns success if _set_config_file_vars was called.
_is_config_file_set() {
	[[ ${_config_file_set} = 1 ]]
}

_get_arch() {
	if use amd64; then
		echo "amd64"
	elif use x86; then
		echo "x86"
	fi
}

_set_config_file_vars() {
	# Setup kernel configuration file name
	local pvr="${PVR}"
	local pv="${PV}"
	if [ "${K_KERNEL_NEW_VERSIONING}" = "1" ]; then
		pvr="$(get_version_component_range 1-2)"
		pv="${pvr}"
		if [ "${PR}" != "r0" ]; then
			pvr+="-${PR}"
		fi
	fi

	K_ROGKERNEL_CONFIG_FILES=()
	K_ROGKERNEL_CONFIG_FILES+=( "${K_ROGKERNEL_NAME}-${pvr}-$(_get_arch).config" )
	K_ROGKERNEL_CONFIG_FILES+=( "${K_ROGKERNEL_NAME}-${pv}-$(_get_arch).config" )
	K_ROGKERNEL_CONFIG_FILES+=( "${K_ROGKERNEL_NAME}-$(_get_arch).config" )

	_config_file_set=1
}

if [ -n "${K_ONLY_SOURCES}" ] ; then
	IUSE="${IUSE}"
	DEPEND="sys-apps/sed"
	RDEPEND="${RDEPEND}"
else
	IUSE="btrfs dmraid dracut iscsi luks lvm mdadm splash"
	DEPEND="app-arch/xz-utils
		sys-apps/sed
		sys-devel/autoconf
		sys-devel/make
		|| ( >=sys-kernel/genkernel-next-5[dmraid(+)?,mdadm(+)?] >=sys-kernel/genkernel-3.4.45-r2 )
		splash? ( x11-themes/redcore-artwork-core )
		lvm? ( sys-fs/lvm2 sys-block/thin-provisioning-tools )
		btrfs? ( sys-fs/btrfs-progs )
		dracut? ( sys-kernel/dracut )"
	RDEPEND="sys-apps/sed
		sys-kernel/linux-firmware"
	if [ -n "${K_REQUIRED_LINUX_FIRMWARE_VER}" ]; then
		RDEPEND+=" >=sys-kernel/linux-firmware-${K_REQUIRED_LINUX_FIRMWARE_VER}"
	fi
fi

# internal function
#
# FUNCTION: _update_depmod
# @USAGE: _update_depmod <-r depmod>
# DESCRIPTION:
# It updates the modules.dep file for the current kernel.
# This is more or less the same of linux-mod update_depmod, with the
# exception of accepting parameter which is passed to depmod -r switch
_update_depmod() {

        # if we haven't determined the version yet, we need too.
        get_version;

	ebegin "Updating module dependencies for ${KV_FULL}"
	if [ -r "${KV_OUT_DIR}"/System.map ]; then
		depmod -ae -F "${KV_OUT_DIR}"/System.map -b "${ROOT}" "${1}"
		eend $?
	else
		ewarn
		ewarn "${KV_OUT_DIR}/System.map not found."
		ewarn "You must manually update the kernel module dependencies using depmod."
		eend 1
		ewarn
	fi
}

redcore-kernel_pkg_setup() {
	einfo "Preparing kernel and its modules"
}

redcore-kernel_src_unpack() {
	local okv="${OKV}"
	if [ -n "${K_ROGKERNEL_SELF_TARBALL_NAME}" ] ; then
		OKV="${PVR}+${K_ROGKERNEL_SELF_TARBALL_NAME}"
	fi
	if [ "${K_KERNEL_NEW_VERSIONING}" = "1" ]; then
		# workaround for kernel-2's universal_unpack assumptions
		UNIPATCH_LIST_DEFAULT= KV_MAJOR=0 kernel-2_src_unpack
	else
		kernel-2_src_unpack
	fi
	if [ -n "${K_ROGKERNEL_FORCE_SUBLEVEL}" ]; then
		# patch out Makefile with proper sublevel
		sed -i "s:^SUBLEVEL = .*:SUBLEVEL = ${K_ROGKERNEL_FORCE_SUBLEVEL}:" \
			"${S}/Makefile" || die
	fi
	OKV="${okv}"
}

redcore-kernel_src_prepare() {
	_set_config_file_vars
}

redcore-kernel_src_compile() {
	if [ -n "${K_ONLY_SOURCES}" ]; then
		kernel-2_src_compile
	else
		_kernel_src_compile
	fi
}

_kernel_copy_config() {
	_is_config_file_set \
		|| die "Kernel configuration file not set. Was redcore-kernel_src_prepare() called?"

	local base_path="${DISTDIR}"
	if [ -n "${K_ROGKERNEL_SELF_TARBALL_NAME}" ]; then
		base_path="${S}/redcore/config"
	fi

	local found= cfg=
	for cfg in "${K_ROGKERNEL_CONFIG_FILES[@]}"; do
		cfg="${base_path}/${cfg}"
		if [ -f "${cfg}" ]; then
			cp "${cfg}" "${1}" || die "cannot copy kernel config ${cfg} -> ${1}"
			elog "Using kernel config: ${cfg}"
			found=1
			break
		fi
	done
	[[ -z "${found}" ]] && die "cannot find kernel configs among: ${K_ROGKERNEL_CONFIG_FILES[*]}"
}

_kernel_src_compile() {
	# disable sandbox
	export SANDBOX_ON=0

	# needed anyway, even if grub use flag is not used here
	if use amd64 || use x86; then
		mkdir -p "${WORKDIR}"/boot/grub
	else
		mkdir -p "${WORKDIR}"/boot
	fi

	einfo "Starting to compile kernel..."
	_kernel_copy_config "${WORKDIR}"/config

	# do some cleanup
	rm -rf "${WORKDIR}"/lib
	rm -rf "${WORKDIR}"/cache
	rm -rf "${S}"/temp

	# creating workdirs
	mkdir "${WORKDIR}"/cache
	mkdir "${S}"/temp

	cd "${S}" || die
	local GKARGS=()
	GKARGS+=( "--no-menuconfig" "--all-ramdisk-modules" "--no-save-config" "--e2fsprogs" "--udev" )
	use btrfs && GKARGS+=( "--btrfs" )
	use dmraid && GKARGS+=( "--dmraid" )
	use iscsi && GKARGS+=( "--iscsi" )
	use mdadm && GKARGS+=( "--mdadm" )
	use luks && GKARGS+=( "--luks" )
	use lvm && GKARGS+=( "--lvm" )

	export DEFAULT_KERNEL_SOURCE="${S}"
	export CMD_KERNEL_DIR="${S}"
	for opt in ${MAKEOPTS}; do
		if [ "${opt:0:2}" = "-j" ]; then
			mkopts="${opt}"
			break
		fi
	done
	[ -z "${mkopts}" ] && mkopts="-j3"

	# Workaround bug in splash_geninitramfs corrupting the initramfs
	# if xz compression is used (newer genkernel >3.4.24)
	local support_comp=$(genkernel --help | grep compress-initramfs-type)
	if [ -n "${support_comp}" ]; then
		GKARGS+=( "--compress-initramfs-type=gzip" )
	fi

	# Use --disklabel if genkernel supports it
	local support_disklabel=$(genkernel --help | grep -- --disklabel)
	if [ -n "${support_disklabel}" ]; then
		GKARGS+=( "--disklabel" )
	fi

	if [ -n "${K_MKIMAGE_KERNEL_ADDRESS}" ]; then
		export LOADADDR="${K_MKIMAGE_KERNEL_ADDRESS}"
	fi
	OLDARCH="${ARCH}"
	unset ARCH
	unset LDFLAGS
	DEFAULT_KERNEL_SOURCE="${S}" CMD_KERNEL_DIR="${S}" genkernel "${GKARGS[@]}" ${K_GENKERNEL_ARGS} \
		--kerneldir="${S}" \
		--kernel-config="${WORKDIR}"/config \
		--cachedir="${WORKDIR}"/cache \
		--makeopts="${mkopts}" \
		--tempdir="${S}"/temp \
		--logfile="${WORKDIR}"/genkernel.log \
		--bootdir="${WORKDIR}"/boot \
		--mountboot \
		--module-prefix="${WORKDIR}"/lib \
		kernel || die "genkernel failed"

	if [ -n "${K_MKIMAGE_KERNEL_ADDRESS}" ]; then
		unset LOADADDR
	fi

	ARCH=${OLDARCH}
}

redcore-kernel_src_install() {
	if [ -n "${K_ONLY_SOURCES}" ]; then
		_kernel_sources_src_install
	else
		_kernel_src_install
	fi
}

_kernel_sources_src_install() {
	_kernel_copy_config ".config"
	kernel-2_src_install
	cd "${D}${KV_OUT_DIR}" || die
	local oldarch="${ARCH}"
	unset ARCH
	if ! use sources_standalone; then
		make modules_prepare || die "failed to run modules_prepare"
		rm .config || die "cannot remove .config"
		rm Makefile || die "cannot remove Makefile"
		rm -f include/linux/version.h
		rm -f include/generated/uapi/linux/version.h
	fi
	ARCH="${oldarch}"
}

_kernel_src_install() {
	dodir "${KV_OUT_DIR}"
	insinto "${KV_OUT_DIR}"

	_kernel_copy_config ".config"
	doins ".config" || die "cannot copy kernel config"
	doins Makefile || die "cannot copy Makefile"
	doins Module.symvers || die "cannot copy Module.symvers"
	doins System.map || die "cannot copy System.map"

	# NOTE: this is a workaround caused by linux-info.eclass not
	# being ported to EAPI=2 yet
	local version_h_dir="include/linux"
	local version_h_dir2="include/generated/uapi/linux"
	local version_h=
	local version_h_src=
	for ver_dir in "${version_h_dir}" "${version_h_dir2}"; do
		version_h="${ROOT}${KV_OUT_DIR/\//}/${ver_dir}/version.h"
		if [ -f "${version_h}" ]; then
			einfo "Discarding previously installed version.h to avoid collisions"
			addwrite "${version_h}"
			rm -f "${version_h}"
		fi

		# Include include/linux/version.h to make Portage happy
		version_h_src="${S}/${ver_dir}/version.h"
		if [ -f "${version_h_src}" ]; then
			dodir "${KV_OUT_DIR}/${ver_dir}"
			insinto "${KV_OUT_DIR}/${ver_dir}"
			doins "${version_h_src}" || die "cannot copy version.h"
		fi
	done

	insinto "/boot"
	doins "${WORKDIR}"/boot/* || die "cannot copy /boot over"
	cp -Rp "${WORKDIR}"/lib/* "${D}/" || die "cannot copy /lib over"

	cd "${D}"/lib/modules/* || die "cannot enter /lib/modules directory, more than one element?"
	# cleanup previous
	rm -f build source || die
	# create sane symlinks
	ln -sf "../../..${KV_OUT_DIR}" source || die "cannot create source symlink"
	ln -sf "../../..${KV_OUT_DIR}" build || die "cannot create build symlink"
	cd "${S}" || die

	# drop ${D}/lib/firmware, virtual/linux-firmwares provides it
	rm -rf "${D}/lib/firmware"
}

redcore-kernel_pkg_preinst() {
	if _is_kernel_binary; then
		mount-boot_pkg_preinst
	fi
}

_get_real_extraversion() {
	make_file="${ROOT}${KV_OUT_DIR}/Makefile"
	local extraver=$(grep -r "^EXTRAVERSION =" "${make_file}" | cut -d "=" -f 2 | head -n 1)
	local trimmed=${extraver%% }
	echo ${trimmed## }
}

_get_release_level() {
	echo "${KV_FULL}"
}

_dracut_initramfs_create() {
	if use amd64 || use x86; then
		if use amd64; then
			local kern_arch="x86_64"
		else
			local kern_arch="x86"
		fi
	fi
	if [ "${PR}" == "r0" ] ; then
		local kver="${PV}-${K_ROGKERNEL_SELF_TARBALL_NAME}"
		else
		local kver="${PV}-${K_ROGKERNEL_SELF_TARBALL_NAME}-${PR}"
	fi
	elog "Generating initramfs for ${kver}, please wait"
	addpredict /etc/ld.so.cache~
	dracut -f --kver="${kver}" "${ROOT}boot/initramfs-genkernel-${kern_arch}-${kver}"
}

_dracut_initramfs_delete() {
	if use amd64 || use x86; then
		if use amd64; then
			local kern_arch="x86_64"
		else
			local kern_arch="x86"
		fi
	fi
	if [ "${PR}" == "r0" ]; then
		local kver="${PV}-${K_ROGKERNEL_SELF_TARBALL_NAME}"
	else
		local kver="${PV}-${K_ROGKERNEL_SELF_TARBALL_NAME}-${PR}"
	fi
	rm -rf "${ROOT}boot/initramfs-genkernel-${kern_arch}-${kver}"

}

_grub2_update_grubcfg() {
	if [[ -x $(which grub2-mkconfig) ]]; then
		elog "Updating GRUB-2 bootloader configuration, please wait"
		$(which grub2-mkconfig) -o "${ROOT}boot/grub/grub.cfg"
	else
		elog "It looks like you're not using GRUB-2, you must update bootloader configuration by hand"
	fi
}

_remove_dkms_modules() {
	if [ "${PR}" == "r0" ] ; then
		local kver="${PV}-${K_ROGKERNEL_SELF_TARBALL_NAME}"
	else
		local kver="${PV}-${K_ROGKERNEL_SELF_TARBALL_NAME}-${PR}"
	fi
	if [[ -x $(which dkms) ]] ; then
		for i in $(dkms status | cut -d " " -f1,2 | sed -e 's/,//g' | sed -e 's/ /\//g' | sed -e 's/://g') ; do
			dkms remove $i -k "${kver}"
		done
	fi
}

redcore-kernel_pkg_postinst() {
	if _is_kernel_binary; then
		# generate initramfs with dracut
		if use dracut ; then
			_dracut_initramfs_create
		fi

		_grub2_update_grubcfg

		kernel-2_pkg_postinst
		local depmod_r=$(_get_release_level)
		_update_depmod "${depmod_r}"

	else
		kernel-2_pkg_postinst
	fi
}

redcore-kernel_pkg_prerm() {
	if _is_kernel_binary; then
		mount-boot_pkg_prerm
	fi
}

redcore-kernel_pkg_postrm() {
	if _is_kernel_binary; then
		_dracut_initramfs_delete
		_remove_dkms_modules
		_grub2_update_grubcfg
	fi
}

# export all the available functions here
case ${EAPI:-0} in
	[01234])
			die "EAPI ${EAPI:-0} is not supported"
esac

EXPORT_FUNCTIONS pkg_setup src_unpack src_prepare \
	src_compile src_install pkg_preinst pkg_postinst pkg_prerm pkg_postrm
