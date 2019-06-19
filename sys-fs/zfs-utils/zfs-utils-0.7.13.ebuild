# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="5"
PYTHON_COMPAT=( python{2_7,3_4,3_5,3_6} )

inherit autotools-utils bash-completion-r1 flag-o-matic python-r1 systemd toolchain-funcs udev

MY_PN="zfs"
MY_P="${MY_PN}-${PV}"

SRC_URI="https://github.com/zfsonlinux/${MY_PN}/releases/download/${MY_P}/${MY_P}.tar.gz"

DESCRIPTION="Userland utilities for ZFS Linux kernel module"
HOMEPAGE="http://zfsonlinux.org/"

LICENSE="BSD-2 CDDL MIT"
SLOT="0"
KEYWORDS="amd64"
IUSE="debug test-suite"

RESTRICT="test"

S="${WORKDIR}/${MY_P}"

COMMON_DEPEND="sys-apps/util-linux
	sys-libs/zlib
	virtual/awk"
DEPEND="${COMMON_DEPEND}
	virtual/pkgconfig"
RDEPEND="${COMMON_DEPEND}
	!=sys-apps/grep-2.13*
	!sys-fs/zfs-fuse
	!prefix? ( virtual/udev )
	test-suite? (
		sys-apps/util-linux
		sys-devel/bc
		sys-block/parted
		sys-fs/lsscsi
		sys-fs/mdadm
		sys-process/procps
		virtual/modutils
		)
	sys-fs/udev-init-scripts
	~sys-fs/spl-utils-${PV}"

AT_M4DIR="config"
AUTOTOOLS_IN_SOURCE_BUILD="1"

src_prepare() {
	# Update paths
	sed -e "s|/sbin/lsmod|/bin/lsmod|" \
		-e "s|/usr/bin/scsi-rescan|/usr/sbin/rescan-scsi-bus|" \
		-e "s|/sbin/parted|/usr/sbin/parted|" \
		-i scripts/common.sh.in

	autotools-utils_src_prepare
}

src_configure() {
	local myeconfargs=(
		--bindir="${EPREFIX}/bin"
		--sbindir="${EPREFIX}/sbin"
		--with-config=user
		--with-dracutdir="/usr/$(get_libdir)/dracut"
		--with-udevdir="$(get_udevdir)"
		--with-blkid
		$(use_enable debug)
	)
	autotools-utils_src_configure

	# prepare systemd unit and helper script
	cat "${FILESDIR}/zfs.service.in" | \
		sed -e "s:@sbindir@:${EPREFIX}/sbin:g" \
			-e "s:@sysconfdir@:${EPREFIX}/etc:g" \
		> "${T}/zfs.service" || die
	cat "${FILESDIR}/zfs-init.sh.in" | \
		sed -e "s:@sbindir@:${EPREFIX}/sbin:g" \
			-e "s:@sysconfdir@:${EPREFIX}/etc:g" \
		> "${T}/zfs-init.sh" || die
}

src_install() {
	autotools-utils_src_install
	gen_usr_ldscript -a uutil nvpair zpool zfs zfs_core
	use test-suite || rm -rf "${ED}usr/share/zfs"

	newbashcomp "${FILESDIR}/bash-completion-r1" zfs
	bashcomp_alias zfs zpool

	exeinto /usr/libexec
	doexe "${T}/zfs-init.sh"
	systemd_dounit "${T}/zfs.service"
}
