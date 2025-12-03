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

LICENSE="NVIDIA-r2 BSD BSD-2 GPL-2 MIT ZLIB curl openssl"
SLOT="4"
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
	!!x11-drivers/nvidia-drivers:3
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

QA_PREBUILT="lib/firmware/* opt/bin/* usr/lib*"

PATCHES=(
	"${FILESDIR}"/nvidia-drivers-470.141.03-clang15.patch
	"${FILESDIR}"/nvidia-modprobe-390.141-uvm-perms.patch
)

pkg_setup() {
	local CONFIG_CHECK="
		PROC_FS
		~DRM_KMS_HELPER
		~SYSVIPC
		~!AMD_MEM_ENCRYPT_ACTIVE_BY_DEFAULT
		~!LOCKDEP
		~!SLUB_DEBUG_ON
		~!X86_KERNEL_IBT
		!DEBUG_MUTEXES
	"

	local ERROR_DRM_KMS_HELPER="CONFIG_DRM_KMS_HELPER: is not set but needed for Xorg auto-detection
	of drivers (no custom config), and for nvidia-drm.modeset=1 if used.
	Cannot be directly selected in the kernel's menuconfig, and may need
	selection of a DRM device even if unused, e.g. CONFIG_DRM_AMDGPU=m or
	DRM_I915=y, DRM_NOUVEAU=m also acceptable if a module and not built-in."

	local ERROR_X86_KERNEL_IBT="CONFIG_X86_KERNEL_IBT: is set and, if the CPU supports the feature,
	this *could* lead to modules load failure with ENDBR errors, or to
	broken CUDA/NVENC. Please ignore if not having issues, but otherwise
	try to unset or pass ibt=off to the kernel's command line." #911142

	CONFIG_CHECK+=" X86_PAT" #817764
}

src_prepare() {
	# make patches usable across versions
	rm nvidia-modprobe && mv nvidia-modprobe{-${PV},} || die
	rm nvidia-persistenced && mv nvidia-persistenced{-${PV},} || die
	rm nvidia-xconfig && mv nvidia-xconfig{-${PV},} || die

	default

	# prevent detection of incomplete kernel DRM support (bug #603818)
	sed 's/defined(CONFIG_DRM/defined(CONFIG_DRM_KMS_HELPER/g' \
		-i kernel/conftest.sh || die

	sed 's/__USER__/nvpd/' \
		nvidia-persistenced/init/systemd/nvidia-persistenced.service.template \
		> "${T}"/nvidia-persistenced.service || die
}

src_compile() {
	tc-export AR CC CXX LD OBJCOPY OBJDUMP PKG_CONFIG
	local -x RAW_LDFLAGS="$(get_abi_LDFLAGS) $(raw-ldflags)" # raw-ldflags.patch

	# latest branches has proper fixes, but legacy have more issues and are
	# not worth the trouble, so doing the lame "fix" for gcc14 (bug #921370)
	# TODO: check if still needed on bumps given this branch is supported,
	# and reminder to cleanup the CC="${KERNEL_CC}" in modargs if removing
	local noerr=(
		-Wno-error=implicit-function-declaration
		-Wno-error=incompatible-pointer-types
	)
	# not *FLAGS to ensure it's used everywhere including conftest.sh
	CC+=" $(test-flags-CC "${noerr[@]}")"

	local xnvflags=-fPIC #840389
	# lto static libraries tend to cause problems without fat objects
	tc-is-lto && xnvflags+=" $(test-flags-CC -ffat-lto-objects)"

	NV_ARGS=(
		PREFIX="${EPREFIX}"/usr
		HOST_CC="$(tc-getBUILD_CC)"
		HOST_LD="$(tc-getBUILD_LD)"
		NV_USE_BUNDLED_LIBJANSSON=0
		NV_VERBOSE=1 DO_STRIP= MANPAGE_GZIP= OUTPUTDIR=out
		XNVCTRL_CFLAGS="${xnvflags}"
	)

	use persistenced && emake "${NV_ARGS[@]}" -C nvidia-persistenced

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
		[FIRMWARE]=/lib/firmware/nvidia/${PV}
		[GLVND_EGL_ICD_JSON]=/usr/share/glvnd/egl_vendor.d
		[VULKAN_ICD_JSON]=/usr/share/vulkan
		[WINE_LIB]=/usr/${libdir}/nvidia/wine
		[XORG_OUTPUTCLASS_CONFIG]=/usr/share/X11/xorg.conf.d

		[GLX_MODULE_SHARED_LIB]=/usr/${libdir}/xorg/modules/extensions
		[GLX_MODULE_SYMLINK]=/usr/${libdir}/xorg/modules
		[XMODULE_SHARED_LIB]=/usr/${libdir}/xorg/modules
	)

	local skip_files=(
		$(usev !X "libGLX_nvidia libglxserver_nvidia libnvidia-ifr")
		libGLX_indirect # non-glvnd unused fallback
		libnvidia-gtk nvidia-{settings,xconfig} # built from source
		# skip wayland-related files, largely broken with 470 at this point
		libnvidia-egl-wayland 10_nvidia_wayland libnvidia-vulkan-producer
	)
	local skip_modules=(
		$(usev !X "nvfbc vdpau xdriver")
		$(usev !dkms gsp)
		installer nvpd # handled separately / built from source
	)
	local skip_types=(
		GLVND_LIB GLVND_SYMLINK EGL_CLIENT.\* GLX_CLIENT.\* # media-libs/libglvnd
		OPENCL_WRAPPER.\* # virtual/opencl
		DOCUMENTATION DOT_DESKTOP .\*_SRC DKMS_CONF # handled separately / unused
	)

	local DOCS=(
		README.txt NVIDIA_Changelog supported-gpus/supported-gpus.json
	)
	local HTML_DOCS=( html/. )
	einstalldocs

	local DISABLE_AUTOFORMATTING=yes
	local DOC_CONTENTS="\
Trusted users should be in the 'video' group to use NVIDIA devices.
You can add yourself by using: gpasswd -a my-user video\

See '${EPREFIX}/etc/modprobe.d/nvidia.conf' for modules options.\

Note that without USE=abi_x86_32 on ${PN}, 32bit applications
(typically using wine / steam) will not be able to use GPU acceleration.\

For additional information or for troubleshooting issues, please see
https://wiki.gentoo.org/wiki/NVIDIA/nvidia-drivers and NVIDIA's own
documentation that is installed alongside this README."
	readme.gentoo_create_doc

	insinto /etc/modprobe.d
	newins "${FILESDIR}"/nvidia-470.conf nvidia.conf

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
			VDPAU_SYMLINK) m[4]=vdpau/; m[5]=${m[5]#vdpau/};; # .so to vdpau/
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

		if [[ ${m[2]} =~ _SYMLINK$ ]]; then
			[[ ${m[4]: -1} == / ]] && m[4]=${m[5]}
			dosym ${m[4]} ${into}/${m[0]}
			continue
		fi
		[[ ${m[0]} =~ ^libnvidia-ngx.so ]] &&
			dosym ${m[0]} ${into}/${m[0]%.so*}.so.1 # soname not in .manifest

		printf -v m[1] %o $((m[1] | 0200)) # 444->644
		insopts -m${m[1]}
		insinto ${into}
		doins ${m[0]}
	done < .manifest || die
	insopts -m0644 # reset

	# MODULE:installer non-skipped extras
	: "$(systemd_get_sleepdir)"
	exeinto "${_#"${EPREFIX}"}"
	doexe systemd/system-sleep/nvidia
	dobin systemd/nvidia-sleep.sh
	systemd_dounit systemd/system/nvidia-{hibernate,resume,suspend}.service

	dobin nvidia-bug-report.sh

	# enabling is needed for sleep to work properly and little reason not to do
	# it unconditionally for a better user experience
	: "$(systemd_get_systemunitdir)"
	local unitdir=${_#"${EPREFIX}"}
	# not using relative symlinks to match systemd's own links
	dosym {"${unitdir}",/etc/systemd/system/systemd-hibernate.service.wants}/nvidia-hibernate.service
	dosym {"${unitdir}",/etc/systemd/system/systemd-hibernate.service.wants}/nvidia-resume.service
	dosym {"${unitdir}",/etc/systemd/system/systemd-suspend.service.wants}/nvidia-suspend.service
	dosym {"${unitdir}",/etc/systemd/system/systemd-suspend.service.wants}/nvidia-resume.service
	# also add a custom elogind hook to do the equivalent of the above
	exeinto /usr/lib/elogind/system-sleep
	newexe "${FILESDIR}"/system-sleep.elogind nvidia
	# <elogind-255.5 used a different path (bug #939216), keep a compat symlink
	# TODO: cleanup after 255.5 been stable for a few months
	dosym {/usr/lib,/"${libdir}"}/elogind/system-sleep/nvidia

	# needed with >=systemd-256 or may fail to resume with some setups
	# https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=1072722
	insinto "${unitdir}"/systemd-homed.service.d
	newins - 10-nvidia.conf <<-EOF
		[Service]
		Environment=SYSTEMD_HOME_LOCK_FREEZE_SESSION=false
	EOF
	insinto "${unitdir}"/systemd-suspend.service.d
	newins - 10-nvidia.conf <<-EOF
		[Service]
		Environment=SYSTEMD_SLEEP_FREEZE_USER_SESSIONS=false
	EOF
	dosym -r "${unitdir}"/systemd-{suspend,hibernate}.service.d/10-nvidia.conf
	dosym -r "${unitdir}"/systemd-{suspend,hybrid-sleep}.service.d/10-nvidia.conf
	dosym -r "${unitdir}"/systemd-{suspend,suspend-then-hibernate}.service.d/10-nvidia.conf

	# symlink non-versioned so nvidia-settings can use it even if misdetected
	dosym nvidia-application-profiles-${PV}-key-documentation \
		${paths[APPLICATION_PROFILE]}/nvidia-application-profiles-key-documentation

	# don't attempt to strip firmware files (silences errors)
	dostrip -x ${paths[FIRMWARE]}

	# sandbox issues with /dev/nvidiactl (and /dev/char wrt bug #904292)
	# are widespread and sometime affect revdeps of packages built with
	# USE=opencl/cuda making it hard to manage in ebuilds (minimal set,
	# ebuilds should handle manually if need others or addwrite)
	insinto /etc/sandbox.d
	newins - 20nvidia <<<'SANDBOX_PREDICT="/dev/nvidiactl:/dev/char"'

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
	ewarn "Be warned/reminded that the 470.xx branch reached end-of-life and"
	ewarn "NVIDIA is no longer fixing issues (including security). Free to keep"
	ewarn "using (for now) but it is recommended to either switch to nouveau or"
	ewarn "replace hardware. Will be kept in-tree while possible, but expect it"
	ewarn "to be removed likely in early 2027 or earlier if major issues arise."
	ewarn
	ewarn "Note that there is no plans to patch in support for kernels branches"
	ewarn "newer than 6.6.x which will be supported upstream until December 2026."

	if [[ $(</proc/cmdline) == *slub_debug=[!-]* ]]; then
		ewarn "Detected that the current kernel command line is using 'slub_debug=',"
		ewarn "this may lead to system instability/freezes with this version of"
		ewarn "${PN}. Bug: https://bugs.gentoo.org/796329"
	fi

	# these can be removed after some time, only to help the transition
	# given users are unlikely to do further custom solutions if it works
	# (see also https://github.com/elogind/elogind/issues/272)
	if grep -riq "^[^#]*HandleNvidiaSleep=yes" "${EROOT}"/etc/elogind/sleep.conf.d/ 2>/dev/null
	then
		ewarn
		ewarn "!!! WARNING !!!"
		ewarn "Detected HandleNvidiaSleep=yes in ${EROOT}/etc/elogind/sleep.conf.d/."
		ewarn "This 'could' cause issues if used in combination with the new hook"
		ewarn "installed by the ebuild to handle sleep using the official upstream"
		ewarn "script. It is recommended to disable the option."
	fi
	if [[ $(realpath "${EROOT}"{/etc,{/usr,}/lib*}/elogind/system-sleep 2>/dev/null | \
		sort | uniq | xargs -d'\n' grep -Ril nvidia 2>/dev/null | wc -l) -gt 2 ]]
	then
		ewarn
		ewarn "!!! WARNING !!!"
		ewarn "Detected a custom script at ${EROOT}{/etc,{/usr,}/lib*}/elogind/system-sleep"
		ewarn "referencing NVIDIA. This version of ${PN} has installed its own"
		ewarn "hook at ${EROOT}/usr/lib/elogind/system-sleep/nvidia and it is recommended"
		ewarn "to remove the custom one to avoid potential issues."
		ewarn
		ewarn "Feel free to ignore this warning if you know the other NVIDIA-related"
		ewarn "scripts can be used together. The warning will be removed in the future."
	fi
	if [[ ${REPLACING_VERSIONS##* } ]] &&
		ver_test ${REPLACING_VERSIONS##* } -lt 470.256.02-r1 # may get repeated
	then
		elog
		elog "For suspend/sleep, 'NVreg_PreserveVideoMemoryAllocations=1' is now default"
		elog "with this version of ${PN}. This is recommended (or required) by"
		elog "major DEs especially with wayland but, *if* experience regressions with"
		elog "suspend, try reverting to =0 in '${EROOT}/etc/modprobe.d/nvidia.conf'."
		elog
		elog "May notably be an issue when using neither systemd nor elogind to suspend."
		elog
		elog "Also, the systemd suspend/hibernate/resume services are now enabled by"
		elog "default, and for openrc+elogind a similar hook has been installed."
	fi
}

pkg_postrm() {
	if [ $(stat -c %d:%i /) == $(stat -c %d:%i /proc/1/root/.) ]; then
		_dracut_initramfs_regen
	fi
}
