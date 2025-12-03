# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools bash-completion-r1 flag-o-matic pam toolchain-funcs udev usr-ldscript

MY_PN="zfs"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Userland utilities for ZFS Linux kernel module"
HOMEPAGE="https://zfsonlinux.org/"

SRC_URI="https://github.com/openzfs/${MY_PN}/releases/download/${MY_P}/${MY_P}.tar.gz"
KEYWORDS="~amd64"
S="${WORKDIR}/${MY_P}"

LICENSE="BSD-2 CDDL MIT"
SLOT="0"
IUSE="debug nls pam test-suite unwind"

DEPEND="
	net-libs/libtirpc:=
	sys-apps/util-linux
	sys-libs/zlib
	virtual/libudev:=
	dev-libs/openssl:=
	pam? ( sys-libs/pam )
	unwind? ( sys-libs/libunwind:= )
"

BDEPEND="app-alternatives/awk
	virtual/pkgconfig
	nls? ( sys-devel/gettext )
"

RDEPEND="${DEPEND}
	app-alternatives/awk
	virtual/udev
	sys-fs/udev-init-scripts
	test-suite? (
		sys-apps/kmod[tools]
		sys-apps/util-linux
		sys-devel/bc
		sys-block/parted
		sys-fs/lsscsi
		sys-fs/mdadm
		sys-process/procps
	)
"

RESTRICT="test"

PATCHES=(
	"${FILESDIR}"/2.1.5-dracut-zfs-missing.patch
)

src_prepare() {
	default

	# Run unconditionally (bug #792627)
	eautoreconf

	# Tries to use /etc/conf.d which we reserve for OpenRC
	sed -i -e '/EnvironmentFile/d' etc/systemd/system/zfs*.in || die

	# prevent errors showing up on zfs-mount stop, #647688
	# openrc will unmount all filesystems anyway.
	sed -i "/^ZFS_UNMOUNT=/ s/yes/no/" "etc/default/zfs.in" || die
}

src_configure() {
	local myconf=(
		--bindir="${EPREFIX}/bin"
		--enable-shared
		--disable-systemd
		--enable-sysvinit
		--localstatedir="${EPREFIX}/var"
		--sbindir="${EPREFIX}/sbin"
		--with-config=user
		--with-dracutdir="${EPREFIX}/usr/lib/dracut"
		--with-udevdir="$(get_udevdir)"
		--with-pamconfigsdir="${EPREFIX}/unwanted_files"
		--with-pammoduledir="$(getpam_mod_dir)"
		--with-vendor=redcore
		$(use_enable debug)
		$(use_enable nls)
		$(use_enable pam)
		$(use_with unwind libunwind)
		--disable-pyzfs
		--disable-static
	)

	econf "${myconf[@]}"
}

src_install() {
	default

	gen_usr_ldscript -a nvpair uutil zfsbootenv zfs zfs_core zpool
	dobashcomp contrib/bash_completion.d/zfs
	bashcomp_alias zfs zpool
	dodir etc/conf.d
	insinto etc/conf.d
	doins "${S}"/etc/default/zfs
	use pam && { rm -rv "${ED}/unwanted_files" || die ; }
	use test-suite || { rm -r "${ED}/usr/share/zfs" || die ; }

	# strip executable bit from conf.d file
	fperms 0644 /etc/conf.d/zfs
}
