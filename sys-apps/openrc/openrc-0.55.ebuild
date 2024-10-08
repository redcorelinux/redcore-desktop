# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit flag-o-matic meson pam toolchain-funcs

DESCRIPTION="OpenRC manages the services, startup and shutdown of a host"
HOMEPAGE="https://github.com/openrc/openrc/"

if [[ ${PV} =~ ^9{4,}$ ]]; then
	EGIT_REPO_URI="https://github.com/OpenRC/${PN}.git"
	inherit git-r3
else
	SRC_URI="https://github.com/OpenRC/openrc/archive/${PV}.tar.gz -> ${P}.tar.gz"
KEYWORDS="~alpha amd64 arm arm64 hppa ~ia64 ~loong ~m68k ~mips ppc ppc64 ~riscv ~s390 sparc x86"
fi

LICENSE="BSD-2"
SLOT="0"
IUSE="+apparmor audit bash caps debug +dkms elogind +havege pam newnet +netifrc selinux +settingsd +splash sysvinit sysv-utils unicode"

COMMON_DEPEND="
	apparmor? (
		sys-apps/apparmor
		sys-apps/apparmor-utils
		sec-policy/apparmor-profiles
	)
	pam? ( sys-libs/pam )
	audit? ( sys-process/audit )
	caps? ( sys-libs/libcap )
	dkms? ( sys-kernel/dkms )
	elogind? ( sys-auth/elogind )
	havege? ( sys-apps/haveged )
	sys-process/psmisc
	selinux? (
		sys-apps/policycoreutils
		>=sys-libs/libselinux-2.6
	)
	settingsd? ( app-admin/openrc-settingsd )
	amd64? ( splash? ( sys-boot/plymouth-openrc-plugin ) )
	>=virtual/logger-1.314.1337"
DEPEND="${COMMON_DEPEND}
	virtual/os-headers"
RDEPEND="${COMMON_DEPEND}
	bash? ( app-shells/bash )
	sysv-utils? (
		!sys-apps/systemd[sysv-utils(-)]
		!sys-apps/sysvinit
	)
	!sysv-utils? ( sysvinit? ( >=sys-apps/sysvinit-2.86-r6[selinux?] ) )
	virtual/tmpfiles
	selinux? (
		>=sec-policy/selinux-base-policy-2.20170204-r4
		>=sec-policy/selinux-openrc-2.20170204-r4
	)
"

PDEPEND="netifrc? ( net-misc/netifrc )"

src_prepare() {
	default
	if use dkms; then
		eapply "${FILESDIR}"/${PN}-dkms.patch
	fi
	eapply "${FILESDIR}"/${PN}-enable-rclogger.patch
}

src_configure() {
	local emesonargs=(
		$(meson_feature audit)
		"-Dbranding=\"Redcore Linux Hardened\""
		$(meson_feature caps capabilities)
		$(meson_use newnet)
		-Dos=Linux
		$(meson_use pam)
		$(meson_feature selinux)
		-Drootprefix="${EPREFIX}"
		-Dshell=$(usex bash /bin/bash /bin/sh)
		$(meson_use sysv-utils sysvinit)
	)
	# export DEBUG=$(usev debug)
	meson_src_configure
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
	meson_install

	keepdir /lib/rc/tmp

	# Setup unicode defaults for silly unicode users
	set_config_yes_no /etc/rc.conf unicode use unicode

	# Cater to the norm
	set_config_yes_no /etc/conf.d/keymaps windowkeys '(' use x86 '||' use amd64 ')'

	# On HPPA, do not run consolefont by default (bug #222889)
	if use hppa; then
		rm -f "${ED}"/etc/runlevels/boot/consolefont
	fi

	# Support for logfile rotation
	insinto /etc/logrotate.d
	newins "${FILESDIR}"/openrc.logrotate openrc

	if use pam; then
		# install gentoo pam.d files
		newpamd "${FILESDIR}"/start-stop-daemon.pam start-stop-daemon
		newpamd "${FILESDIR}"/start-stop-daemon.pam supervise-daemon
	fi

	# install documentation
	dodoc *.md
}

pkg_preinst() {
	# avoid default thrashing in conf.d files when possible #295406
	if [[ -e "${EROOT}"/etc/conf.d/hostname ]] ; then
		(
		unset hostname HOSTNAME
		source "${EROOT}"/etc/conf.d/hostname
		: ${hostname:=${HOSTNAME}}
		[[ -n ${hostname} ]] && set_config /etc/conf.d/hostname hostname "${hostname}"
		)
	fi

	# set default interactive shell to sulogin if it exists
	set_config /etc/rc.conf rc_shell /sbin/sulogin "#" test -e /sbin/sulogin
	return 0
}

pkg_postinst() {
	# add dkms to boot runlevel
	if [ -e "${ROOT}"/etc/init.d/dkms ] && use dkms; then
		if [ "$(rc-config list boot | grep dkms)" != "" ]; then
			einfo > /dev/null 2>&1
		else
			"${ROOT}"/sbin/rc-update add dkms boot > /dev/null 2>&1
		fi
	fi
	# move dbus to boot runlevel
	if [ -e "${ROOT}"/etc/init.d/dbus ] && use elogind; then
		if [ "$(rc-config list boot | grep dbus)" != "" ]; then
			einfo > /dev/null 2>&1
		elif [ "$(rc-config list default | grep dbus)" != "" ]; then
			"${ROOT}"/sbin/rc-update del dbus default > /dev/null 2>&1
			"${ROOT}"/sbin/rc-update add dbus boot > /dev/null 2>&1
		else
			"${ROOT}"/sbin/rc-update add dbus boot > /dev/null 2>&1
		fi
	fi
	# consolekit -> elogind migration
	if [ -e "${ROOT}"/etc/init.d/elogind ] && use elogind; then
		if [ "$(rc-config list boot | grep elogind)" != "" ]; then
			einfo > /dev/null 2>&1
		else
			"${ROOT}"/sbin/rc-update add elogind boot > /dev/null 2>&1
		fi

		if [ "$(rc-config list default | grep consolekit)" != "" ]; then
			"${ROOT}"/sbin/rc-update del consolekit default > /dev/null 2>&1
		fi

		if [ "$(rc-config list default | grep cgmanager)" != "" ]; then
			"${ROOT}"/sbin/rc-update del cgmanager default > /dev/null 2>&1
		fi
	fi
	# add apparmor to boot runlevel
	if [ -e "${ROOT}"/etc/init.d/apparmor ] && use apparmor; then
		if [ "$(rc-config list boot | grep apparmor)" != "" ]; then
			einfo > /dev/null 2>&1
		else
			"${ROOT}"/sbin/rc-update add apparmor boot > /dev/null 2>&1
		fi
	fi
	# add haveged to default runlevel
	if [ -e "${ROOT}"/etc/init.d/haveged ] && use havege; then
		if [ "$(rc-config list default | grep haveged)" != "" ]; then
			einfo > /dev/null 2>&1
		else
			"${ROOT}"/sbin/rc-update add haveged default > /dev/null 2>&1
		fi
	fi
	# add openrc-settingsd to default level, disable ntpd
	# this allows time & date to be set to network time zone in various desktop environments
	if [ -e "${ROOT}"/etc/init.d/openrc-settingsd ] && use settingsd; then
		if [ "$(rc-config list default | grep openrc-settingsd)" != "" ]; then
			einfo > /dev/null 2>&1
		else
			"${ROOT}"/sbin/rc-update add openrc-settingsd default > /dev/null 2>&1
		fi

		if [ "$(rc-config list default | grep ntpd)" != "" ]; then
			"${ROOT}"/sbin/rc-update del ntpd default > /dev/null 2>&1
		fi
	fi
	# urandom -> seedrng migration
	if [ -e "${ROOT}"/etc/init.d/seedrng ] && [ ! -e"${ROOT}"/etc/init.d/urandom ]; then
		if [ "$(rc-config list boot | grep urandom)" != "" ]; then
			"${ROOT}"/sbin/rc-update del urandom boot > /dev/null 2>&1
			"${ROOT}"/sbin/rc-update add seedrng boot > /dev/null 2>&1
		else
			"${ROOT}"/sbin/rc-update add seedrng boot > /dev/null 2>&1
		fi
	fi
	# syslog-ng -> metalog migration
	if [ -e "${ROOT}"/etc/init.d/metalog ]; then
		if [ "$(rc-config list default | grep metalog)" != "" ]; then
			einfo > /dev/null 2>&1
		else
			"${ROOT}"/sbin/rc-update add metalog default > /dev/null 2>&1
		fi

		if [ "$(rc-config list default | grep syslog-ng)" != "" ]; then
			"${ROOT}"/sbin/rc-update del syslog-ng default > /dev/null 2>&1
		fi
	fi
}
