# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit flag-o-matic multilib-minimal portability toolchain-funcs unpacker

NV_URI="https://us.download.nvidia.com/XFree86/"
AMD64_NV_PACKAGE="NVIDIA-Linux-x86_64-${PV}"
DESCRIPTION="NVIDIA Accelerated Graphics Driver"

SRC_URI="amd64? ( ${NV_URI}Linux-x86_64/${PV}/${AMD64_NV_PACKAGE}.run )"

EMULTILIB_PKG="true"
KEYWORDS="-* ~amd64"
LICENSE="GPL-2 NVIDIA-r2"
SLOT="0"

IUSE="acpi compat +dkms +libglvnd multilib +tools wayland +X"
REQUIRED_USE="tools? ( X )"

COMMON="
	acct-group/video
	acct-user/nvpd
	net-libs/libtirpc
	>=sys-libs/glibc-2.6.1
	X? (
		>=x11-libs/libvdpau-1.0[${MULTILIB_USEDEP}]
		app-misc/pax-utils
		libglvnd? ( media-libs/libglvnd[X,${MULTILIB_USEDEP}] )
	)
"

DEPEND="${COMMON}"

RDEPEND="
	${COMMON}
	>=virtual/opencl-3
	!!x11-drivers/nvidia-drivers-legacy
	acpi? ( sys-power/acpid )
	dkms? ( ~sys-kernel/${PN}-dkms-${PV}:${SLOT} )
	tools? ( ~x11-misc/nvidia-settings-${PV}:${SLOT} )
	wayland? (
		dev-libs/wayland[${MULTILIB_USEDEP}]
		>=gui-libs/egl-wayland-1.1.7-r1
	)
	X? (
		<x11-base/xorg-server-1.20.99:=
		>=x11-libs/libX11-1.6.2[${MULTILIB_USEDEP}]
		>=x11-libs/libXext-1.3.2[${MULTILIB_USEDEP}]
		sys-libs/zlib[${MULTILIB_USEDEP}]
	)
"

QA_PREBUILT="opt/* usr/lib*"
S=${WORKDIR}/
PATCHES=(
	"${FILESDIR}"/dkms.patch
	"${FILESDIR}"/locale.patch
)

pkg_setup() {

	# try to turn off distcc and ccache for people that have a problem with it
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

# Install nvidia library:
# the first parameter is the library to install
# the second parameter is the provided soversion
# the third parameter is the target directory if it is not /usr/lib
donvidia() {
	# Full path to library
	nv_LIB="${1}"

	# SOVER to use
	nv_SOVER="$(scanelf -qF'%S#F' ${nv_LIB})"

	# Where to install
	nv_DEST="${2}"

	# Get just the library name
	nv_LIBNAME=$(basename "${nv_LIB}")

	if [[ "${nv_DEST}" ]]; then
		exeinto ${nv_DEST}
		action="doexe"
	else
		nv_DEST="/usr/$(get_libdir)"
		action="dolib.so"
	fi

	# Install the library
	${action} ${nv_LIB} || die "failed to install ${nv_LIBNAME}"

	# If the library has a SONAME and SONAME does not match the library name,
	# then we need to create a symlink
	if [[ ${nv_SOVER} ]] && ! [[ "${nv_SOVER}" = "${nv_LIBNAME}" ]]; then
		dosym ${nv_LIBNAME} ${nv_DEST}/${nv_SOVER}
	fi

	dosym ${nv_LIBNAME} ${nv_DEST}/${nv_LIBNAME/.so*/.so}
}

src_install() {
	# blacklist nouveau
	insinto /etc/modprobe.d
	doins "${FILESDIR}"/nouveau.conf

	# NVIDIA kernel <-> userspace driver config lib
	donvidia ${NV_OBJ}/libnvidia-cfg.so.${NV_SOVER}

	# NVIDIA framebuffer capture library
	donvidia ${NV_OBJ}/libnvidia-fbc.so.${NV_SOVER}

	# NVIDIA video encode/decode <-> CUDA
	donvidia ${NV_OBJ}/libnvcuvid.so.${NV_SOVER}
	donvidia ${NV_OBJ}/libnvidia-encode.so.${NV_SOVER}

	if use X; then
		# Xorg DDX driver
		insinto /usr/$(get_libdir)/xorg/modules/drivers
		doins ${NV_X11}/nvidia_drv.so

		# Xorg GLX driver
		donvidia ${NV_X11}/libglxserver_nvidia.so.${NV_SOVER} \
			/usr/$(get_libdir)/nvidia/xorg

		# Xorg nvidia.conf
		if has_version '>=x11-base/xorg-server-1.16'; then
			insinto /usr/share/X11/xorg.conf.d
			newins ${FILESDIR}/nvidia-drm-outputclass.conf 50-nvidia-drm-outputclass.conf
		fi

		insinto /usr/share/glvnd/egl_vendor.d
		doins ${NV_X11}/10_nvidia.json
	fi

	insinto /etc/vulkan/icd.d
	doins nvidia_icd.json

	insinto /etc/vulkan/implicit_layer.d
	doins nvidia_layers.json

	# OpenCL ICD for NVIDIA
	insinto /etc/OpenCL/vendors
	doins ${NV_OBJ}/nvidia.icd

	# Helper Apps
	exeinto /opt/bin/

	if use X; then
		doexe ${NV_OBJ}/nvidia-xconfig
	fi

	doexe ${NV_OBJ}/nvidia-cuda-mps-control
	doexe ${NV_OBJ}/nvidia-cuda-mps-server
	doexe ${NV_OBJ}/nvidia-debugdump
	doexe ${NV_OBJ}/nvidia-persistenced
	doexe ${NV_OBJ}/nvidia-smi

	# install nvidia-modprobe setuid and symlink in /usr/bin (bug #505092)
	doexe ${NV_OBJ}/nvidia-modprobe
#	fowners root:video /opt/bin/nvidia-modprobe
#	fperms 4710 /opt/bin/nvidia-modprobe
	dosym /{opt,usr}/bin/nvidia-modprobe

	doman nvidia-cuda-mps-control.1
	doman nvidia-modprobe.1
	doman nvidia-persistenced.1
	newinitd "${FILESDIR}/nvidia-smi.init" nvidia-smi
	newconfd "${FILESDIR}/nvidia-persistenced.conf" nvidia-persistenced
	newinitd "${FILESDIR}/nvidia-persistenced.init" nvidia-persistenced

	if has_multilib_profile && use multilib; then
		local OABI=${ABI}
		for ABI in $(multilib_get_enabled_abis); do
			src_install-libs
		done
		ABI=${OABI}
		unset OABI
	else
		src_install-libs
	fi

	is_final_abi || die "failed to iterate through all ABIs"

	# Docs
	newdoc "${NV_DOC}/README.txt" README
	dodoc "${NV_DOC}/NVIDIA_Changelog"
	doman "${NV_MAN}"/nvidia-smi.1
	use X && doman "${NV_MAN}"/nvidia-xconfig.1
	doman "${NV_MAN}"/nvidia-cuda-mps-control.1

	docinto html
	dodoc -r ${NV_DOC}/html/*
}

src_install-libs() {
	local inslibdir=$(get_libdir)
	if use libglvnd; then
		local GL_ROOT="/usr/$(get_libdir)"
	else
		local GL_ROOT="/usr/$(get_libdir)/opengl/nvidia/lib"
	fi
	local CL_ROOT="/usr/$(get_libdir)/OpenCL/vendors/nvidia"
	local nv_libdir="${NV_OBJ}"

	if has_multilib_profile && [[ ${ABI} == "x86" ]]; then
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
			"libnvidia-allocator.so.${NV_SOVER}"
			"libnvidia-eglcore.so.${NV_SOVER}"
			"libnvidia-encode.so.${NV_SOVER}"
			"libnvidia-fbc.so.${NV_SOVER}"
			"libnvidia-glcore.so.${NV_SOVER}"
			"libnvidia-glsi.so.${NV_SOVER}"
			"libnvidia-glvkspirv.so.${NV_SOVER}"
			"libnvidia-ifr.so.${NV_SOVER}"
			"libnvidia-opencl.so.${NV_SOVER}"
			"libnvidia-ptxjitcompiler.so.${NV_SOVER}"
			"libnvidia-opticalflow.so.${NV_SOVER}"
			"libvdpau_nvidia.so.${NV_SOVER}"
			"libnvidia-ml.so.${NV_SOVER}"
			"libnvidia-tls.so.${NV_SOVER}"
		)
		if ! use libglvnd; then
			NV_GLX_LIBRARIES+=(
				"libEGL.so.$( [[ ${ABI} == "amd64" ]] && usex compat ${NV_SOVER} 1.1.0 || echo 1.1.0) ${GL_ROOT}"
				"libGL.so.1.7.0 ${GL_ROOT}"
				"libGLESv1_CM.so.1.2.0 ${GL_ROOT}"
				"libGLESv2.so.2.1.0 ${GL_ROOT}"
				"libGLX.so.0 ${GL_ROOT}"
				"libGLdispatch.so.0 ${GL_ROOT}"
				"libOpenGL.so.0 ${GL_ROOT}"
			)
		fi

		if has_multilib_profile && [[ ${ABI} == "amd64" ]]; then
			NV_GLX_LIBRARIES+=(
				"libnvidia-cbl.so.${NV_SOVER}"
				"libnvidia-cfg.so.${NV_SOVER}"
				"libnvidia-ngx.so.${NV_SOVER}"
				"libnvidia-rtcore.so.${NV_SOVER}"
				"libnvoptix.so.${NV_SOVER}"
			)
		fi

		for NV_LIB in "${NV_GLX_LIBRARIES[@]}"; do
			donvidia "${nv_libdir}"/${NV_LIB}
		done
	fi
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
