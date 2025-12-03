# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop flag-o-matic multilib readme.gentoo-r1
inherit systemd toolchain-funcs unpacker user-info

NV_URI="https://download.nvidia.com/XFree86/"

DESCRIPTION="NVIDIA Accelerated Graphics Driver"
HOMEPAGE="https://www.nvidia.com/download/index.aspx"
SRC_URI="
	${NV_URI}Linux-x86_64/${PV}/NVIDIA-Linux-x86_64-${PV}.run
	$(printf "${NV_URI}%s/%s-${PV}.tar.bz2 " \
		nvidia-{installer,modprobe,persistenced,xconfig}{,})
"
# nvidia-installer is unused but here for GPL-2's "distribute sources"
S=${WORKDIR}

LICENSE="NVIDIA-r2 BSD BSD-2 GPL-2 MIT"
SLOT="3"
KEYWORDS="-* amd64"
IUSE="abi_x86_32 abi_x86_64 +acpi +dkms +persistenced +tools +X"
RESTRICT="strip"

COMMON_DEPEND="
	acct-group/video
	persistenced? (
		acct-user/nvpd
		net-libs/libtirpc:=
	)
"
RDEPEND="
	${COMMON_DEPEND}
	sys-libs/glibc
	!!x11-drivers/nvidia-drivers:4
	!!x11-drivers/nvidia-drivers:5
	acpi? ( sys-power/acpid )
	dkms? ( ~sys-kernel/${PN}-dkms-${PV}:${SLOT} )
	X? (
		media-libs/libglvnd[X,abi_x86_32(-)?]
		x11-libs/libX11[abi_x86_32(-)?]
		x11-libs/libXext[abi_x86_32(-)?]
	)
"
DEPEND="
	${COMMON_DEPEND}
	x11-base/xorg-proto
	x11-libs/libX11
	x11-libs/libXext
"
BDEPEND="
	app-alternatives/awk
	sys-devel/m4
	virtual/pkgconfig
"
PDEPEND="
	tools? ( x11-misc/nvidia-settings:${SLOT} )
"

QA_PREBUILT="opt/bin/* usr/lib*"

PATCHES=(
	# note: no plans to add patches for newer kernels here, when the last
	# working 6.1.x LTS is EOL then 390 will simply be removed from the tree
	"${FILESDIR}"/nvidia-modprobe-390.141-uvm-perms.patch
)

pkg_setup() {
	local CONFIG_CHECK="
		PROC_FS
		~DRM_KMS_HELPER
		~SYSVIPC
		~!AMD_MEM_ENCRYPT_ACTIVE_BY_DEFAULT
		~!LOCKDEP
		~!X86_KERNEL_IBT
		!DEBUG_MUTEXES
	"

	local ERROR_DRM_KMS_HELPER="CONFIG_DRM_KMS_HELPER: is not set but needed for Xorg auto-detection
	of drivers (no custom config), and optional nvidia-drm.modeset=1.
	With 390.xx drivers, also used by a GLX workaround needed for OpenGL.
	Cannot be directly selected in the kernel's menuconfig, and may need
	selection of a DRM device even if unused, e.g. CONFIG_DRM_AMDGPU=m or
	DRM_I915=y, DRM_NOUVEAU=m also acceptable if a module and not built-in."

	local ERROR_X86_KERNEL_IBT="CONFIG_X86_KERNEL_IBT: is set and, if the CPU supports the feature,
	this will likely lead to modules load failure with ENDBR errors.
	Please ignore if not having issues, but otherwise try to unset or
	pass ibt=off to the kernel's command line." #911142

	CONFIG_CHECK+=" X86_PAT" #817764
}

src_prepare() {
	# make patches usable across versions
	rm nvidia-modprobe && mv nvidia-modprobe{-${PV},} || die
	rm nvidia-persistenced && mv nvidia-persistenced{-${PV},} || die
	rm nvidia-xconfig && mv nvidia-xconfig{-${PV},} || die

	eapply "${FILESDIR}"/nvidia-drivers-390.154-clang15.patch

	default

	# prevent detection of incomplete kernel DRM support (bug #603818)
	sed 's/defined(CONFIG_DRM/defined(CONFIG_DRM_KMS_HELPER/g' \
		-i kernel/conftest.sh || die

	sed 's/__USER__/nvpd/' \
		nvidia-persistenced/init/systemd/nvidia-persistenced.service.template \
		> "${T}"/nvidia-persistenced.service || die

	# use alternative vulkan icd option if USE=-X (bug #909181)
	sed "s/__NV_VK_ICD__/lib$(usex X GLX EGL)_nvidia.so.0/" \
		nvidia_icd.json.template > nvidia_icd.json || die

	# 390 has legacy glx needing a modified .conf (bug #713546)
	# directory is not quite right, but kept for any existing custom xorg.conf
	sed "s|@LIBDIR@|${EPREFIX}/usr/$(get_libdir)|" \
		"${FILESDIR}"/nvidia-drm-outputclass-390.conf > nvidia-drm-outputclass.conf || die
}

src_compile() {
	tc-export AR CC CXX LD OBJCOPY OBJDUMP PKG_CONFIG
	local -x RAW_LDFLAGS="$(get_abi_LDFLAGS) $(raw-ldflags)" # raw-ldflags.patch

	# latest branches has proper fixes, but legacy have more issues and are
	# not worth the trouble, so doing the lame "fix" for gcc14 (bug #921370)
	local noerr=(
		-Wno-error=implicit-function-declaration
		-Wno-error=incompatible-pointer-types
	)
	# not *FLAGS to ensure it's used everywhere including conftest.sh
	CC+=" $(test-flags-CC "${noerr[@]}")"

	NV_ARGS=(
		PREFIX="${EPREFIX}"/usr
		HOST_CC="$(tc-getBUILD_CC)"
		HOST_LD="$(tc-getBUILD_LD)"
		NV_USE_BUNDLED_LIBJANSSON=0
		NV_VERBOSE=1 DO_STRIP= MANPAGE_GZIP= OUTPUTDIR=out
	)

	if use persistenced; then
		# 390.xx persistenced does not auto-detect libtirpc
		LIBS=$(${PKG_CONFIG} --libs libtirpc || die) \
			common_cflags=$(${PKG_CONFIG} --cflags libtirpc || die) \
			emake "${NV_ARGS[@]}" -C nvidia-persistenced
	fi

	emake "${NV_ARGS[@]}" -C nvidia-modprobe
	use X && emake "${NV_ARGS[@]}" -C nvidia-xconfig
}

src_install() {
	local libdir=$(get_libdir) libdir32=$(ABI=x86 get_libdir)

	NV_ARGS+=( DESTDIR="${D}" LIBDIR="${ED}"/usr/${libdir} )

	local -A paths=(
		[APPLICATION_PROFILE]=/usr/share/nvidia
		[CUDA_ICD]=/etc/OpenCL/vendors
		[EGL_EXTERNAL_PLATFORM_JSON]=/usr/share/egl/egl_external_platform.d
		[GLVND_EGL_ICD_JSON]=/usr/share/glvnd/egl_vendor.d
		[VULKAN_ICD_JSON]=/usr/share/vulkan/icd.d
		[XORG_OUTPUTCLASS_CONFIG]=/usr/share/X11/xorg.conf.d

		[GLX_MODULE_SHARED_LIB]=/usr/${libdir}/xorg/modules/extensions
		[GLX_MODULE_SYMLINK]=/usr/${libdir}/extensions/nvidia
		[XMODULE_SHARED_LIB]=/usr/${libdir}/xorg/modules
		[XMODULE_SYMLINK]=/usr/${libdir}/xorg/modules
	)

	local skip_files=(
		$(usev !X "libGLX_nvidia libglx libnvidia-ifr")
		libGLX_indirect # non-glvnd unused fallback
		libnvidia-gtk nvidia-{settings,xconfig} # built from source
		libnvidia-egl-wayland 10_nvidia_wayland # gui-libs/egl-wayland
	)
	local skip_modules=(
		$(usev !X "nvfbc vdpau xdriver")
		installer nvpd # handled separately / built from source
	)
	local skip_types=(
		GLVND_LIB GLVND_SYMLINK EGL_CLIENT.\* GLX_CLIENT.\* # media-libs/libglvnd
		OPENCL_WRAPPER.\* # virtual/opencl
		DOCUMENTATION DOT_DESKTOP # handled separately
		XMODULE_NEWSYM # use xorg's libwfb.so, nvidia also keeps it if it exists
		.\*_SRC DKMS_CONF LIBGL_LA OPENGL_HEADER # unused
	)

	local DOCS=(
		README.txt NVIDIA_Changelog
	)
	local HTML_DOCS=( html/. )
	einstalldocs

	local DISABLE_AUTOFORMATTING=yes
	local DOC_CONTENTS="\
Trusted users should be in the 'video' group to use NVIDIA devices.
You can add yourself by using: gpasswd -a my-user video\

390.xx libglvnd support is partial and requires different Xorg modules
for working OpenGL/GLX. If using the default Xorg configuration these
should be used automatically, otherwise manually add the ModulePath
from: '${EPREFIX}/${paths[XORG_OUTPUTCLASS_CONFIG]#/}/nvidia-drm-outputclass.conf'\

Note that NVIDIA is no longer offering support for the unified memory
module (nvidia-uvm) on x86 (32bit), as such the module is missing.
This means OpenCL/CUDA (and related, like nvenc) cannot be used.
Other functions, like OpenGL, will continue to work.

Support from NVIDIA for 390.xx will end in December 2022, how long
Gentoo will be able to reasonably support it beyond that is unknown.
If wish to continue using this hardware, should consider switching
to the Nouveau open source driver.
https://nvidia.custhelp.com/app/answers/detail/a_id/3142/

For additional information or for troubleshooting issues, please see
https://wiki.gentoo.org/wiki/NVIDIA/nvidia-drivers and NVIDIA's own
documentation that is installed alongside this README."
	readme.gentoo_create_doc

	insinto /etc/modprobe.d
	newins "${FILESDIR}"/nvidia-390.conf nvidia.conf

	emake "${NV_ARGS[@]}" -C nvidia-modprobe install
	fowners :video /usr/bin/nvidia-modprobe #505092
	fperms 4710 /usr/bin/nvidia-modprobe

	if use persistenced; then
		emake "${NV_ARGS[@]}" -C nvidia-persistenced install
		newconfd "${FILESDIR}"/nvidia-persistenced.confd nvidia-persistenced
		newinitd "${FILESDIR}"/nvidia-persistenced.initd nvidia-persistenced
		systemd_dounit "${T}"/nvidia-persistenced.service
	fi

	use X && emake "${NV_ARGS[@]}" -C nvidia-xconfig install

	# mimic nvidia-installer by reading .manifest to install files
	# 0:file 1:perms 2:type 3+:subtype/arguments -:module
	local m into
	while IFS=' ' read -ra m; do
		! [[ ${#m[@]} -ge 2 && ${m[-1]} =~ MODULE: ]] ||
			[[ " ${m[0]##*/}" =~ ^(\ ${skip_files[*]/%/.*|\\} )$ ]] ||
			[[ " ${m[2]}" =~ ^(\ ${skip_types[*]/%/|\\} )$ ]] ||
			has ${m[-1]#MODULE:} "${skip_modules[@]}" && continue

		case ${m[2]} in
			MANPAGE)
				gzip -dc ${m[0]} | newman - ${m[0]%.gz}; assert
				continue
			;;
			GLX_MODULE_SYMLINK|XMODULE_NEWSYM)
				# messy symlinks for non-glvnd xorg modules overrides put
				# in a different directory to avoid collisions (390-only)
				m[4]=../../xorg/modules/${m[3]#/}${m[4]}
				m[3]=/
			;;
			TLS_LIB) [[ ${m[4]} == CLASSIC ]] && continue;; # segfaults (bug #785289)
			VDPAU_SYMLINK) m[4]=vdpau/; m[5]=${m[5]#vdpau/};; # .so to vdpau/
			VULKAN_ICD_JSON) m[0]=${m[0]%.template};;
		esac

		if [[ -v 'paths[${m[2]}]' ]]; then
			into=${paths[${m[2]}]}
		elif [[ ${m[2]} == *_BINARY ]]; then
			into=/opt/bin
		elif [[ ${m[3]} == COMPAT32 ]]; then
			use abi_x86_32 || continue
			into=/usr/${libdir32}
		elif [[ ${m[2]} == *_@(LIB|SYMLINK) ]]; then
			into=/usr/${libdir}
		else
			die "No known installation path for ${m[0]}"
		fi
		[[ ${m[3]: -2} == ?/ ]] && into+=/${m[3]%/}
		[[ ${m[4]: -2} == ?/ ]] && into+=/${m[4]%/}

		if [[ ${m[2]} =~ _SYMLINK$|_NEWSYM$ ]]; then
			[[ ${m[4]: -1} == / ]] && m[4]=${m[5]}
			dosym ${m[4]} ${into}/${m[0]}
			continue
		fi

		printf -v m[1] %o $((m[1] | 0200)) # 444->644
		insopts -m${m[1]}
		insinto ${into}
		doins ${m[0]}
	done < .manifest || die
	insopts -m0644 # reset

	# MODULE:installer non-skipped extras
	dolib.so libnvidia-cfg.so.${PV}
	dosym libnvidia-cfg.so.${PV} /usr/${libdir}/libnvidia-cfg.so.1
	dosym libnvidia-cfg.so.${PV} /usr/${libdir}/libnvidia-cfg.so

	dobin nvidia-bug-report.sh

	# symlink non-versioned so nvidia-settings can use it even if misdetected
	dosym nvidia-application-profiles-${PV}-key-documentation \
		${paths[APPLICATION_PROFILE]}/nvidia-application-profiles-key-documentation

	# sandbox issues with /dev/nvidiactl are widespread and sometime
	# affect revdeps of packages built with USE=opencl/cuda making it
	# hard to manage in ebuilds (minimal set, ebuilds should handle
	# manually if need others or addwrite)
	insinto /etc/sandbox.d
	newins - 20nvidia <<<'SANDBOX_PREDICT="/dev/nvidiactl"'

	# Dracut does not include /etc/modprobe.d if hostonly=no, but we do need this
	# to ensure that the nouveau blacklist is applied
	# https://github.com/dracut-ng/dracut-ng/issues/674
	# https://bugs.gentoo.org/932781
	dodir /usr/lib/dracut/dracut.conf.d
	if use dkms; then
		echo "install_items+=\" ${EPREFIX}/etc/modprobe.d/nvidia.conf \"" >> \
			"${ED}/usr/lib/dracut/dracut.conf.d/10-${PN}.conf" || die
	fi
}

_dracut_initramfs_regen() {
	if [ -x $(which dracut) ]; then
		dracut -N -f --no-hostonly-cmdline
	fi
}

pkg_preinst() {
	# set video group id based on live system (bug #491414)
	local g=$(egetent group video | cut -d: -f3)
	[[ ${g} =~ ^[0-9]+$ ]] || die "Failed to determine video group id (got '${g}')"
	sed -i "s/@VIDEOGID@/${g}/" "${ED}"/etc/modprobe.d/nvidia.conf || die
}

pkg_postinst() {
	if [ $(stat -c %d:%i /) == $(stat -c %d:%i /proc/1/root/.) ]; then
		_dracut_initramfs_regen
	fi

	readme.gentoo_print_elog
	ewarn
	ewarn "Be warned/reminded that the 390.xx branch reached end-of-life and"
	ewarn "NVIDIA is no longer fixing issues (including security). Free to keep"
	ewarn "using (for now) but it is recommended to either switch to nouveau or"
	ewarn "replace hardware. Will be kept in-tree while possible, but expect it"
	ewarn "to be removed likely in early 2027 or earlier if major issues arise."
	ewarn
	ewarn "Note that there is no plans to patch in support for kernels branches"
	ewarn "newer than 6.1.x which will be supported upstream until December 2026."
}

pkg_postrm() {
	if [ $(stat -c %d:%i /) == $(stat -c %d:%i /proc/1/root/.) ]; then
		_dracut_initramfs_regen
	fi
}
