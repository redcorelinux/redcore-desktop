# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop flag-o-matic readme.gentoo-r1
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

LICENSE="
	NVIDIA-2025 Apache-2.0 Boost-1.0 BSD BSD-2 GPL-2 MIT ZLIB
	curl openssl public-domain
"
SLOT="5"
KEYWORDS="-* amd64"
IUSE="abi_x86_32 abi_x86_64 +acpi +dkms +persistenced +powerd +tools +wayland +X"
RESTRICT="strip"

COMMON_DEPEND="
	acct-group/video
	X? ( x11-libs/libpciaccess )
	persistenced? (
		acct-user/nvpd
		net-libs/libtirpc:=
	)
"
RDEPEND="
	${COMMON_DEPEND}
	dev-libs/openssl:0/3
	sys-libs/glibc
	!!x11-drivers/nvidia-drivers:3
	!!x11-drivers/nvidia-drivers:4
	acpi? ( sys-power/acpid )
	dkms? ( ~sys-kernel/${PN}-dkms-${PV}:${SLOT} )
	X? (
		media-libs/libglvnd[X,abi_x86_32(-)?]
		x11-libs/libX11[abi_x86_32(-)?]
		x11-libs/libXext[abi_x86_32(-)?]
	)
	powerd? ( sys-apps/dbus[abi_x86_32(-)?] )
	wayland? (
		>=gui-libs/egl-gbm-1.1.1-r2[abi_x86_32(-)?]
		|| (
			>=gui-libs/egl-wayland-1.1.13.1[abi_x86_32(-)?]
			gui-libs/egl-wayland2[abi_x86_32(-)?]
		)
		X? ( gui-libs/egl-x11[abi_x86_32(-)?] )
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
	"${FILESDIR}"/nvidia-modprobe-390.141-uvm-perms.patch
)

pkg_setup() {
	local CONFIG_CHECK="
		PROC_FS
		~DRM_KMS_HELPER
		~DRM_FBDEV_EMULATION
		~SYSVIPC
		~!LOCKDEP
		~!SLUB_DEBUG_ON
		!DEBUG_MUTEXES
		$(usev powerd '~CPU_FREQ')
	"

	CONFIG_CHECK+=" DRM_TTM_HELPER"

	CONFIG_CHECK+=" X86_PAT" #817764

	CONFIG_CHECK+=" MMU_NOTIFIER" #843827

	local drm_helper_msg="Cannot be directly selected in the kernel's config menus, and may need
	selection of a DRM device even if unused, e.g. CONFIG_DRM_QXL=m or
	DRM_AMDGPU=m (among others, consult the kernel config's help), can
	also use DRM_NOUVEAU=m as long as built as module *not* built-in."
	local ERROR_DRM_KMS_HELPER="CONFIG_DRM_KMS_HELPER: is not set but needed for Xorg auto-detection
	of drivers (no custom config), and for wayland / nvidia-drm.modeset=1.
	${drm_helper_msg}"
	local ERROR_DRM_TTM_HELPER="CONFIG_DRM_TTM_HELPER: is not set but is needed to compile when using
	kernel version 6.11.x or newer while DRM_FBDEV_EMULATION is set.
	${drm_helper_msg}"
	local ERROR_DRM_FBDEV_EMULATION="CONFIG_DRM_FBDEV_EMULATION: is not set but is needed for
	nvidia-drm.fbdev=1 support, currently off-by-default and it could
	be ignored, but note that is due to change in the future."
	local ERROR_MMU_NOTIFIER="CONFIG_MMU_NOTIFIER: is not set but needed to build with USE=kernel-open.
	Cannot be directly selected in the kernel's menuconfig, and may need
	selection of another option that requires it such as CONFIG_KVM."
	local ERROR_PREEMPT_RT="CONFIG_PREEMPT_RT: is set but is unsupported by NVIDIA upstream and
	will fail to build unless the env var IGNORE_PREEMPT_RT_PRESENCE=1 is
	set. Please do not report issues if run into e.g. kernel panics while
	ignoring this."
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

	# adjust service files
	sed 's/__USER__/nvpd/' \
		nvidia-persistenced/init/systemd/nvidia-persistenced.service.template \
		> "${T}"/nvidia-persistenced.service || die
	sed -i "s|/usr|${EPREFIX}/opt|" systemd/system/nvidia-powerd.service || die

	# use alternative vulkan icd option if USE=-X (bug #909181)
	use X || sed -i 's/"libGLX/"libEGL/' nvidia_{layers,icd}.json || die

	# enable nvidia-drm.modeset=1 by default with USE=wayland
	cp "${FILESDIR}"/nvidia-580.conf "${T}"/nvidia.conf || die
	use !wayland || sed -i '/^#.*modeset=1$/s/^#//' "${T}"/nvidia.conf || die
}

src_compile() {
	tc-export AR CC CXX LD OBJCOPY OBJDUMP PKG_CONFIG

	local xnvflags=-fPIC #840389
	# lto static libraries tend to cause problems without fat objects
	tc-is-lto && xnvflags+=" $(test-flags-CC -ffat-lto-objects)"

	NV_ARGS=(
		PREFIX="${EPREFIX}"/usr
		HOST_CC="$(tc-getBUILD_CC)"
		HOST_LD="$(tc-getBUILD_LD)"
		BUILD_GTK2LIB=
		NV_USE_BUNDLED_LIBJANSSON=0
		NV_VERBOSE=1 DO_STRIP= MANPAGE_GZIP= OUTPUTDIR=out
		WAYLAND_AVAILABLE=$(usex wayland 1 0)
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
		[GBM_BACKEND_LIB_SYMLINK]=/usr/${libdir}/gbm
		[GLVND_EGL_ICD_JSON]=/usr/share/glvnd/egl_vendor.d
		[OPENGL_DATA]=/usr/share/nvidia
		[VULKANSC_ICD_JSON]=/usr/share/vulkansc
		[VULKAN_ICD_JSON]=/usr/share/vulkan
		[WINE_LIB]=/usr/${libdir}/nvidia/wine
		[XORG_OUTPUTCLASS_CONFIG]=/usr/share/X11/xorg.conf.d

		[GLX_MODULE_SHARED_LIB]=/usr/${libdir}/xorg/modules/extensions
		[GLX_MODULE_SYMLINK]=/usr/${libdir}/xorg/modules
		[XMODULE_SHARED_LIB]=/usr/${libdir}/xorg/modules
	)

	local skip_files=(
		$(usev !X "libGLX_nvidia libglxserver_nvidia")
		libGLX_indirect # non-glvnd unused fallback
		libnvidia-{gtk,wayland-client} nvidia-{settings,xconfig} # from source
		libnvidia-egl-gbm 15_nvidia_gbm # gui-libs/egl-gbm
		libnvidia-egl-wayland 10_nvidia_wayland # gui-libs/egl-wayland
		libnvidia-egl-xcb 20_nvidia_xcb.json # gui-libs/egl-x11
		libnvidia-egl-xlib 20_nvidia_xlib.json # gui-libs/egl-x11
		libnvidia-pkcs11.so # using the openssl3 version instead
	)
	local skip_modules=(
		$(usev !X "nvfbc vdpau xdriver")
		$(usev !dkms gsp)
		$(usev !powerd nvtops)
		installer nvpd # handled separately / built from source
	)
	local skip_types=(
		GLVND_LIB GLVND_SYMLINK EGL_CLIENT.\* GLX_CLIENT.\* # media-libs/libglvnd
		OPENCL_WRAPPER.\* # virtual/opencl
		DOCUMENTATION DOT_DESKTOP .\*_SRC DKMS_CONF SYSTEMD_UNIT # handled separately / unused
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

Be warned that USE=kernel-open may need to be either enabled or
disabled for certain cards to function:
- GTX 50xx (blackwell) and higher require it to be enabled
- GTX 1650 and higher (pre-blackwell) should work either way
- Older cards require it to be disabled

For additional information or for troubleshooting issues, please see
https://wiki.gentoo.org/wiki/NVIDIA/nvidia-drivers and NVIDIA's own
documentation that is installed alongside this README."
	readme.gentoo_create_doc

	insinto /etc/modprobe.d
	doins "${T}"/nvidia.conf

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
			GBM_BACKEND_LIB_SYMLINK) m[4]=../${m[4]};; # missing ../
			VDPAU_SYMLINK) m[4]=vdpau/; m[5]=${m[5]#vdpau/};; # .so to vdpau/
		esac

		if [[ -v 'paths[${m[2]}]' ]]; then
			into=${paths[${m[2]}]}
		elif [[ ${m[2]} == EXPLICIT_PATH ]]; then
			into=${m[3]}
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
		# avoid portage warning due to missing soname links in manifest
		[[ ${m[0]} =~ ^libnvidia-ngx.so ]] &&
			dosym ${m[0]} ${into}/${m[0]%.so*}.so.1

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
	systemd_dounit systemd/system/nvidia-{hibernate,resume,suspend,suspend-then-hibernate}.service

	dobin nvidia-bug-report.sh

	insinto /usr/share/nvidia/files.d
	doins sandboxutils-filelist.json

	# MODULE:powerd extras
	if use powerd; then
		newinitd "${FILESDIR}"/nvidia-powerd.initd nvidia-powerd #923117
		systemd_dounit systemd/system/nvidia-powerd.service

		insinto /usr/share/dbus-1/system.d
		doins nvidia-dbus.conf
	fi

	# enabling is needed for sleep to work properly and little reason not to do
	# it unconditionally for a better user experience
	: "$(systemd_get_systemunitdir)"
	local unitdir=${_#"${EPREFIX}"}
	# not using relative symlinks to match systemd's own links
	dosym {"${unitdir}",/etc/systemd/system/systemd-hibernate.service.wants}/nvidia-hibernate.service
	dosym {"${unitdir}",/etc/systemd/system/systemd-hibernate.service.wants}/nvidia-resume.service
	dosym {"${unitdir}",/etc/systemd/system/systemd-suspend-then-hibernate.service.wants}/nvidia-suspend-then-hibernate.service
	dosym {"${unitdir}",/etc/systemd/system/systemd-suspend-then-hibernate.service.wants}/nvidia-resume.service
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

	# sandbox issues with /dev/nvidiactl others (bug #904292,#921578)
	# are widespread and sometime affect revdeps of packages built with
	# USE=opencl/cuda making it hard to manage in ebuilds (minimal set,
	# ebuilds should handle manually if need others or addwrite)
	insinto /etc/sandbox.d
	newins - 20nvidia <<<'SANDBOX_PREDICT="/dev/nvidiactl:/dev/nvidia-caps:/dev/char"'

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

	if [[ $(</proc/cmdline) == *slub_debug=[!-]* ]]; then
		ewarn "\nDetected that the current kernel command line is using 'slub_debug=',"
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
