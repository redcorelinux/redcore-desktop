# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit eutils flag-o-matic multilib-minimal portability toolchain-funcs unpacker

NV_URI="http://http.download.nvidia.com/XFree86/"
AMD64_NV_PACKAGE="NVIDIA-Linux-x86_64-${PV}"

DESCRIPTION="NVIDIA Accelerated Graphics Driver"
HOMEPAGE="http://www.nvidia.com/ http://www.nvidia.com/Download/Find.aspx"
SRC_URI="amd64? ( ${NV_URI}Linux-x86_64/${PV}/${AMD64_NV_PACKAGE}.run )"

LICENSE="GPL-2 NVIDIA-r2"
SLOT="390"
KEYWORDS="-* ~amd64"
RESTRICT="bindist mirror strip"
EMULTILIB_PKG="true"

IUSE="acpi +dkms multilib +tools wayland +X"

COMMON="
	acct-group/video
	acct-user/nvpd
	net-libs/libtirpc
	X? (
			>=x11-libs/libvdpau-1.0[${MULTILIB_USEDEP}]
			media-libs/libglvnd[X,${MULTILIB_USEDEP}]
	)"
DEPEND="${COMMON}"
PDEPEND="
	tools? ( ~x11-misc/nvidia-settings-${PV}:${SLOT} )
"
RDEPEND="
	${COMMON}
	>=virtual/opencl-3
	!!x11-drivers/nvidia-drivers:470
	!!x11-drivers/nvidia-drivers:515
	!!x11-drivers/nvidia-drivers:525
	acpi? ( sys-power/acpid )
	dkms? ( ~sys-kernel/${PN}-dkms-${PV}:${SLOT} )
	wayland? ( dev-libs/wayland[${MULTILIB_USEDEP}] )
	X? (
		>=x11-libs/libX11-1.6.2[${MULTILIB_USEDEP}]
		>=x11-libs/libXext-1.3.2[${MULTILIB_USEDEP}]
		sys-libs/zlib[${MULTILIB_USEDEP}]
	)
"

QA_PREBUILT="opt/* usr/lib*"

PATCHES=(
	"${FILESDIR}"/dkms390.patch
)

S=${WORKDIR}/

pkg_setup() {
	export DISTCC_DISABLE=1
	export CCACHE_DISABLE=1

	NV_DOC="${S}"
	NV_OBJ="${S}"
	NV_SRC="${S}/kernel"
	NV_MAN="${S}"
	NV_X11="${S}"
	NV_SOVER=${PV}
}

src_prepare() {
	default
	local man_file
	for man_file in "${NV_MAN}"/*1.gz; do
		gunzip $man_file || die
	done

	if ! [ -f nvidia_icd.json ]; then
		cp nvidia_icd.json.template nvidia_icd.json || die
		sed -i -e 's:__NV_VK_ICD__:libGLX_nvidia.so.0:g' nvidia_icd.json || die
	fi
}

donvidia() {
	nv_LIB="${1}"
	nv_SOVER="$(scanelf -qF'%S#F' ${nv_LIB})"
	nv_DEST="${2}"
	nv_LIBNAME=$(basename "${nv_LIB}")

	if [[ "${nv_DEST}" ]]; then
		exeinto ${nv_DEST}
		action="doexe"
	else
		nv_DEST="/usr/$(get_libdir)"
		action="dolib.so"
	fi

	${action} ${nv_LIB} || die "failed to install ${nv_LIBNAME}"

	if [[ ${nv_SOVER} ]] && ! [[ "${nv_SOVER}" = "${nv_LIBNAME}" ]]; then
		dosym ${nv_LIBNAME} ${nv_DEST}/${nv_SOVER}
	fi

	dosym ${nv_LIBNAME} ${nv_DEST}/${nv_LIBNAME/.so*/.so}
}

src_install-libs() {
	local inslibdir=$(get_libdir)
	local GL_ROOT="/usr/$(get_libdir)"
	local CL_ROOT="/usr/$(get_libdir)/OpenCL/vendors/nvidia"
	local nv_libdir="${NV_OBJ}"

	if  has_multilib_profile && [[ ${ABI} == "x86" ]]; then
		nv_libdir="${NV_OBJ}"/32
	fi

	if use X; then
		NV_GLX_LIBRARIES=(
			"libEGL_nvidia.so.${NV_SOVER} ${GL_ROOT}"
			"libGLESv1_CM_nvidia.so.${NV_SOVER} ${GL_ROOT}"
			"libGLESv2_nvidia.so.${NV_SOVER} ${GL_ROOT}"
			"libGLX_nvidia.so.${NV_SOVER} ${GL_ROOT}"
			"libOpenCL.so.1.0.0 ${CL_ROOT}"
			"libcuda.so.${NV_SOVER}"
			"libnvcuvid.so.${NV_SOVER}"
			"libnvidia-compiler.so.${NV_SOVER}"
			"libnvidia-eglcore.so.${NV_SOVER}"
			"libnvidia-encode.so.${NV_SOVER}"
			"libnvidia-fatbinaryloader.so.${NV_SOVER}"
			"libnvidia-fbc.so.${NV_SOVER}"
			"libnvidia-glcore.so.${NV_SOVER}"
			"libnvidia-glsi.so.${NV_SOVER}"
			"libnvidia-ifr.so.${NV_SOVER}"
			"libnvidia-opencl.so.${NV_SOVER}"
			"libnvidia-ptxjitcompiler.so.${NV_SOVER}"
			"libvdpau_nvidia.so.${NV_SOVER}"
			"libnvidia-ml.so.${NV_SOVER}"
			"tls/libnvidia-tls.so.${NV_SOVER}"
		)

		if use wayland && has_multilib_profile && [[ ${ABI} == "amd64" ]];
		then
			NV_GLX_LIBRARIES+=(
				"libnvidia-egl-wayland.so.1.0.2"
			)
		fi

		if has_multilib_profile && [[ ${ABI} == "amd64" ]];
		then
			NV_GLX_LIBRARIES+=(
				"libnvidia-wfb.so.${NV_SOVER}"
			)
		fi

		for NV_LIB in "${NV_GLX_LIBRARIES[@]}"; do
			donvidia "${nv_libdir}"/${NV_LIB}
		done
	fi
}

src_install() {
	donvidia ${NV_OBJ}/libnvidia-cfg.so.${NV_SOVER}
	donvidia ${NV_OBJ}/libnvidia-fbc.so.${NV_SOVER}
	donvidia ${NV_OBJ}/libnvcuvid.so.${NV_SOVER}
	donvidia ${NV_OBJ}/libnvidia-encode.so.${NV_SOVER}

	if has_multilib_profile && use multilib; then
		local OABI=${ABI}
		for ABI in $(get_install_abis); do
			src_install-libs
		done
		ABI=${OABI}
		unset OABI
	else
		src_install-libs
	fi

	is_final_abi || die "failed to iterate through all ABIs"

	if use X; then
		insinto /usr/$(get_libdir)/xorg/modules/drivers
		doins ${NV_X11}/nvidia_drv.so

		donvidia ${NV_X11}/libglx.so.${NV_SOVER} /usr/$(get_libdir)/nvidia/xorg

		insinto /usr/share/X11/xorg.conf.d
		newins "${FILESDIR}"/nvidia-drm-outputclass.conf 50-nvidia-drm-outputclass.conf

		insinto /usr/share/glvnd/egl_vendor.d
		doins ${NV_X11}/10_nvidia.json

		insinto /etc/vulkan/icd.d
		doins ${NV_X11}/nvidia_icd.json

		exeinto /opt/bin
		doexe ${NV_OBJ}/nvidia-xconfig

		doman "${NV_MAN}"/nvidia-xconfig.1
	fi

	if use wayland; then
		insinto /usr/share/egl/egl_external_platform.d
		doins ${NV_X11}/10_nvidia_wayland.json
	fi

	insinto /etc/modprobe.d
	doins "${FILESDIR}"/nouveau.conf

	insinto /etc/OpenCL/vendors
	doins ${NV_OBJ}/nvidia.icd

	exeinto /opt/bin/
	doexe ${NV_OBJ}/nvidia-cuda-mps-control
	doexe ${NV_OBJ}/nvidia-cuda-mps-server
	doexe ${NV_OBJ}/nvidia-debugdump
	doexe ${NV_OBJ}/nvidia-persistenced
	doexe ${NV_OBJ}/nvidia-smi
	doexe ${NV_OBJ}/nvidia-modprobe

	fowners root:video /opt/bin/nvidia-modprobe
	fperms 4710 /opt/bin/nvidia-modprobe
	dosym /{opt,usr}/bin/nvidia-modprobe

	newinitd "${FILESDIR}/nvidia-smi.init" nvidia-smi
	newconfd "${FILESDIR}/nvidia-persistenced.conf" nvidia-persistenced
	newinitd "${FILESDIR}/nvidia-persistenced.init" nvidia-persistenced

	doman "${NV_MAN}"/nvidia-smi.1
	doman "${NV_MAN}"/nvidia-cuda-mps-control.1
	doman "${NV_MAN}"/nvidia-modprobe.1
	doman "${NV_MAN}"/nvidia-persistenced.1
}

_dracut_initramfs_regen() {
	if [ -x $(which dracut) ]; then
		dracut -N -f --no-hostonly-cmdline
	fi
}

pkg_preinst() {
	if [ -d "${ROOT}"/usr/lib/opengl/nvidia ]; then
		rm -rf "${ROOT}"/usr/lib/opengl/nvidia/*
	fi

	if [ -e "${ROOT}"/etc/env.d/09nvidia ]; then
		rm -f "${ROOT}"/etc/env.d/09nvidia
	fi
}

pkg_postinst() {
	if [ $(stat -c %d:%i /) == $(stat -c %d:%i /proc/1/root/.) ]; then
		_dracut_initramfs_regen
	fi
}

pkg_postrm() {
	if [ $(stat -c %d:%i /) == $(stat -c %d:%i /proc/1/root/.) ]; then
		_dracut_initramfs_regen
	fi
}
