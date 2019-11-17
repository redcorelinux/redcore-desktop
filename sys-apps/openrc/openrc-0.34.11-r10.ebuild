# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit flag-o-matic pam toolchain-funcs

DESCRIPTION="OpenRC manages the services, startup and shutdown of a host"
HOMEPAGE="https://github.com/openrc/openrc/"

if [[ ${PV} == "9999" ]]; then
	EGIT_REPO_URI="git://github.com/OpenRC/${PN}.git"
	inherit git-r3
else
	SRC_URI="https://github.com/${PN}/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="alpha amd64 arm arm64 hppa ~ia64 ~m68k ~mips ppc ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~sparc-fbsd ~x86-fbsd"
fi

LICENSE="BSD-2"
SLOT="0"
IUSE="+apparmor audit debug +dkms elogind ncurses pam newnet +plugin prefix +netifrc selinux +settingsd static-libs
	unicode kernel_linux kernel_FreeBSD"

COMMON_DEPEND="kernel_FreeBSD? ( || ( >=sys-freebsd/freebsd-ubin-9.0_rc sys-process/fuser-bsd ) )
	ncurses? ( sys-libs/ncurses:0= )
	pam? (
		sys-auth/pambase
		sys-libs/pam
	)
	apparmor? ( sys-apps/apparmor
		sys-apps/apparmor-utils
		sec-policy/apparmor-profiles
	)
	audit? ( sys-process/audit )
	dkms? ( sys-kernel/dkms  )
	elogind? ( sys-auth/elogind )
	kernel_linux? (
		sys-process/psmisc
		!<sys-process/procps-3.3.9-r2
	)
	plugin? ( sys-boot/plymouth-openrc-plugin )
	selinux? (
		sys-apps/policycoreutils
		>=sys-libs/libselinux-2.6
	)
	!<sys-apps/baselayout-2.1-r1
	!<sys-fs/udev-init-scripts-27"
DEPEND="${COMMON_DEPEND}
	virtual/os-headers
	ncurses? ( virtual/pkgconfig )
	settingsd? ( app-admin/openrc-settingsd )"
RDEPEND="${COMMON_DEPEND}
	!prefix? (
		kernel_linux? (
			>=sys-apps/sysvinit-2.86-r6[selinux?]
			virtual/tmpfiles
		)
		kernel_FreeBSD? ( sys-freebsd/freebsd-sbin )
	)
	selinux? (
		>=sec-policy/selinux-base-policy-2.20170204-r4
		>=sec-policy/selinux-openrc-2.20170204-r4
	)
"

PDEPEND="netifrc? ( net-misc/netifrc )"

src_prepare() {
	default

	sed -i 's:0444:0644:' mk/sys.mk || die

	if [[ ${PV} == "9999" ]] ; then
		local ver="git-${EGIT_VERSION:0:6}"
		sed -i "/^GITVER[[:space:]]*=/s:=.*:=${ver}:" mk/gitver.mk || die
	fi

	if use dkms ; then
		epatch "${FILESDIR}"/${PN}-dkms.patch
	fi

	epatch "${FILESDIR}"/${PN}-enable-rclogger.patch
	epatch "${FILESDIR}"/${PN}-disable-cgroupsv2.patch
}

src_compile() {
	unset LIBDIR #266688

	MAKE_ARGS="${MAKE_ARGS}
		LIBNAME=$(get_libdir)
		LIBEXECDIR=${EPREFIX}/$(get_libdir)/rc
		MKNET=$(usex newnet)
		MKSELINUX=$(usex selinux)
		MKAUDIT=$(usex audit)
		MKPAM=$(usev pam)
		MKSTATICLIBS=$(usex static-libs)"

	local brand="Unknown"
	if use kernel_linux ; then
		MAKE_ARGS="${MAKE_ARGS} OS=Linux"
		brand="Linux"
	elif use kernel_FreeBSD ; then
		MAKE_ARGS="${MAKE_ARGS} OS=FreeBSD"
		brand="FreeBSD"
	fi
	export BRANDING="Redcore ${brand}"
	use prefix && MAKE_ARGS="${MAKE_ARGS} MKPREFIX=yes PREFIX=${EPREFIX}"
	export DEBUG=$(usev debug)
	export MKTERMCAP=$(usev ncurses)

	tc-export CC AR RANLIB
	emake ${MAKE_ARGS}
}

# set_config <file> <option name> <yes value> <no value> test
# a value of "#" will just comment out the option
set_config() {
	local file="${ED}/$1" var=$2 val com
	eval "${@:5}" && val=$3 || val=$4
	[[ ${val} == "#" ]] && com="#" && val='\2'
	sed -i -r -e "/^#?${var}=/{s:=([\"'])?([^ ]*)\1?:=\1${val}\1:;s:^#?:${com}:}" "${file}"
}

set_config_yes_no() {
	set_config "$1" "$2" YES NO "${@:3}"
}

src_install() {
	emake ${MAKE_ARGS} DESTDIR="${D}" install

	# move the shared libs back to /usr so ldscript can install
	# more of a minimal set of files
	# disabled for now due to #270646
	#mv "${ED}"/$(get_libdir)/lib{einfo,rc}* "${ED}"/usr/$(get_libdir)/ || die
	#gen_usr_ldscript -a einfo rc
	gen_usr_ldscript libeinfo.so
	gen_usr_ldscript librc.so

	if ! use kernel_linux; then
		keepdir /$(get_libdir)/rc/init.d
	fi
	keepdir /$(get_libdir)/rc/tmp

	# Backup our default runlevels
	dodir /usr/share/"${PN}"
	cp -PR "${ED}"/etc/runlevels "${ED}"/usr/share/${PN} || die
	rm -rf "${ED}"/etc/runlevels

	# Setup unicode defaults for silly unicode users
	set_config_yes_no /etc/rc.conf unicode use unicode

	# Cater to the norm
	set_config_yes_no /etc/conf.d/keymaps windowkeys '(' use x86 '||' use amd64 ')'

	# On HPPA, do not run consolefont by default (bug #222889)
	if use hppa; then
		rm -f "${ED}"/usr/share/openrc/runlevels/boot/consolefont
	fi

	# Support for logfile rotation
	insinto /etc/logrotate.d
	newins "${FILESDIR}"/openrc.logrotate openrc

	# install gentoo pam.d files
	newpamd "${FILESDIR}"/start-stop-daemon.pam start-stop-daemon
	newpamd "${FILESDIR}"/start-stop-daemon.pam supervise-daemon

	# install documentation
	dodoc ChangeLog *.md
	if use newnet; then
		dodoc README.newnet
	fi
}

add_boot_init() {
	local initd=$1
	local runlevel=${2:-boot}
	# if the initscript is not going to be installed and is not
	# currently installed, return
	[[ -e "${ED}"/etc/init.d/${initd} || -e "${EROOT}"etc/init.d/${initd} ]] \
		|| return
	[[ -e "${EROOT}"etc/runlevels/${runlevel}/${initd} ]] && return

	# if runlevels dont exist just yet, then create it but still flag
	# to pkg_postinst that it needs real setup #277323
	if [[ ! -d "${EROOT}"etc/runlevels/${runlevel} ]] ; then
		mkdir -p "${EROOT}"etc/runlevels/${runlevel}
		touch "${EROOT}"etc/runlevels/.add_boot_init.created
	fi

	elog "Auto-adding '${initd}' service to your ${runlevel} runlevel"
	ln -snf /etc/init.d/${initd} "${EROOT}"etc/runlevels/${runlevel}/${initd}
}
add_boot_init_mit_config() {
	local config=$1 initd=$2
	if [[ -e ${EROOT}${config} ]] ; then
		if [[ -n $(sed -e 's:#.*::' -e '/^[[:space:]]*$/d' "${EROOT}"${config}) ]] ; then
			add_boot_init ${initd}
		fi
	fi
}

pkg_preinst() {
	local f LIBDIR=$(get_libdir)

	# avoid default thrashing in conf.d files when possible #295406
	if [[ -e "${EROOT}"etc/conf.d/hostname ]] ; then
		(
		unset hostname HOSTNAME
		source "${EROOT}"etc/conf.d/hostname
		: ${hostname:=${HOSTNAME}}
		[[ -n ${hostname} ]] && set_config /etc/conf.d/hostname hostname "${hostname}"
		)
	fi

	# set default interactive shell to sulogin if it exists
	set_config /etc/rc.conf rc_shell /sbin/sulogin "#" test -e /sbin/sulogin

	# termencoding was added in 0.2.1 and needed in boot
	has_version ">=sys-apps/openrc-0.2.1" || add_boot_init termencoding

	# swapfiles was added in 0.9.9 and needed in boot (february 2012)
	has_version ">=sys-apps/openrc-0.9.9" || add_boot_init swapfiles

	if ! has_version ">=sys-apps/openrc-0.11"; then
		add_boot_init sysfs sysinit
	fi

	if ! has_version ">=sys-apps/openrc-0.11.3" ; then
		migrate_udev_mount_script
		add_boot_init tmpfiles.setup boot
	fi

	# these were added in 0.12.
	if ! has_version ">=sys-apps/openrc-0.12"; then
		add_boot_init loopback
		add_boot_init tmpfiles.dev sysinit

		# ensure existing /etc/conf.d/net is not removed
		# undoes the hack to get around CONFIG_PROTECT in openrc-0.11.8 and earlier
		# this needs to stay in openrc ebuilds for a long time. :(
		# Added in 0.12.
		if [[ -f "${EROOT}"etc/conf.d/net ]]; then
			einfo "Modifying conf.d/net to keep it from being removed"
			cat <<-EOF >>"${EROOT}"etc/conf.d/net

# The network scripts are now part of net-misc/netifrc
# In order to avoid sys-apps/${P} from removing this file, this comment was
# added; you can safely remove this comment.  Please see
# /usr/share/doc/netifrc*/README* for more information.
EOF
		fi
	fi
	has_version ">=sys-apps/openrc-0.14" || add_boot_init binfmt

	if ! has_version ">=sys-apps/openrc-0.18.3"; then
		add_boot_init mtab
		if [[ -f "${EROOT}"etc/mtab ]] && [[ ! -L "${EROOT}"etc/mtab ]]; then
			ewarn "${EROOT}etc/mtab will be replaced with a"
			ewarn "symbolic link to /proc/self/mounts on the next"
			ewarn "reboot."
			ewarn "Change the setting in ${EROOT}etc/conf.d/mtab"
			ewarn "if you do not want this to happen."
		fi
	fi
}

# >=OpenRC-0.11.3 requires udev-mount to be in the sysinit runlevel with udev.
migrate_udev_mount_script() {
	if [ -e "${EROOT}"etc/runlevels/sysinit/udev -a \
		! -e "${EROOT}"etc/runlevels/sysinit/udev-mount ]; then
		add_boot_init udev-mount sysinit
	fi
	return 0
}

pkg_postinst() {
	local LIBDIR=$(get_libdir)

	# Make our runlevels if they don't exist
	if [[ ! -e "${EROOT}"etc/runlevels ]] || [[ -e "${EROOT}"etc/runlevels/.add_boot_init.created ]] ; then
		einfo "Copying across default runlevels"
		cp -RPp "${EROOT}"usr/share/${PN}/runlevels "${EROOT}"etc
		rm -f "${EROOT}"etc/runlevels/.add_boot_init.created
	else
		if [[ ! -e "${EROOT}"etc/runlevels/sysinit/devfs ]] ; then
			mkdir -p "${EROOT}"etc/runlevels/sysinit
			cp -RPp "${EROOT}"usr/share/${PN}/runlevels/sysinit/* \
				"${EROOT}"etc/runlevels/sysinit
		fi
		if [[ ! -e "${EROOT}"etc/runlevels/shutdown/mount-ro ]] ; then
			mkdir -p "${EROOT}"etc/runlevels/shutdown
			cp -RPp "${EROOT}"usr/share/${PN}/runlevels/shutdown/* \
				"${EROOT}"etc/runlevels/shutdown
		fi
		if [[ ! -e "${EROOT}"etc/runlevels/nonetwork/local ]]; then
			cp -RPp "${EROOT}"usr/share/${PN}/runlevels/nonetwork \
				"${EROOT}"etc/runlevels
		fi
	fi

	if use kernel_linux && [[ "${EROOT}" = "/" ]]; then
		if ! /$(get_libdir)/rc/sh/migrate-to-run.sh; then
			ewarn "The dependency data could not be migrated to /run/openrc."
			ewarn "This means you need to reboot your system."
		fi
	fi

	# update the dependency tree after touching all files #224171
	[[ "${EROOT}" = "/" ]] && "${EROOT}/${LIBDIR}"/rc/bin/rc-depend -u

	if use newnet && [ ! -e "${EROOT}"etc/runlevels/boot/network ]; then
		ewarn "Please add the network service to your boot runlevel"
		ewarn "as soon as possible. Not doing so could leave you with a system"
		ewarn "without networking."
		ewarn
	fi

	# Redcore Linux tweaks:

	#1 : add dkms service to boot runlevel
	if [ -e "${ROOT}"etc/init.d/dkms ] && use dkms; then
		if [ "$(rc-config list boot | grep dkms)" != "" ]; then
			ewarn "found dkms service in boot runlevel, skiping"
		else
			ewarn "not found dkms service in boot runlevel, enabling"
			"${ROOT}"sbin/rc-update add dkms boot
		fi
	fi

	# Tweaks #2 and #3 are part of consolekit -> elogind migration plan
	# In order to properly integrate elogind into Redcore Linux's boot process
	# We must follow a few steps :
	# step 1 : move dbus service to boot runlevel (elogind needs it)
	# step 2 : enable elogind service in boot runlevel (uses dbus from step 1)
	# step 3 : disable consolekit && cgmanager services
	# We also must be sure we don't break existing setups
	# So we make everything elogind USE conditional

	#2 : move dbus service to boot runlevel
	if [ -e "${ROOT}"etc/init.d/dbus ] && use elogind; then
		if [ "$(rc-config list boot | grep dbus)" != "" ]; then
			ewarn
			ewarn "found dbus service in boot runlevel, skiping"
		elif [ "$(rc-config list default | grep dbus)" != "" ]; then
			ewarn "found dbus service in default runlevel, moving"
			"${ROOT}"sbin/rc-update del dbus default
			"${ROOT}"sbin/rc-update add dbus boot
		else
			ewarn "not found dbus service in boot runlevel, enabling"
			"${ROOT}"sbin/rc-update add dbus boot
		fi
	fi

	#3 : enable elogind service && disable consolekit && cgmanager services
	if [ -e "${ROOT}"etc/init.d/elogind ] && use elogind; then
		if [ "$(rc-config list boot | grep elogind)" != "" ]; then
			ewarn "found elogind service in boot runlevel, skiping"
		else
			ewarn "not found elogind service in boot runlevel, enabling"
			"${ROOT}"sbin/rc-update add elogind boot
		fi

		if [ "$(rc-config list default | grep consolekit)" != "" ]; then
			ewarn "found consolekit service in default runlevel, disabling"
			"${ROOT}"sbin/rc-update del consolekit default
		fi

		if [ "$(rc-config list default | grep cgmanager)" != "" ]; then
			ewarn "found cgmanager service in default runlevel, disabling"
			"${ROOT}"sbin/rc-update del cgmanager default
		fi
	fi

	#4 : add apparmor service to boot runlevel
	if [ -e "${ROOT}"/etc/init.d/apparmor ] && use apparmor; then
		if [ "$(rc-config list boot | grep apparmor)" != "" ]; then
			ewarn "found apparmor service in boot runlevel, skipping"
		else
			ewarn "not found apparmor service in boot runlevel, enabling"
			"${ROOT}"sbin/rc-update add apparmor boot
		fi
	fi
}