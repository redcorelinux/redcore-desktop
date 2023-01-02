# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DISTUTILS_OPTIONAL=1
PYTHON_COMPAT=( python3_{7,8,9,10} )

inherit bash-completion-r1 distutils-r1 flag-o-matic pam toolchain-funcs udev

MY_PN="zfs"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Userland utilities for ZFS Linux kernel module"
HOMEPAGE="https://zfsonlinux.org/"

SRC_URI="https://github.com/openzfs/${PN}/releases/download/${MY_P}/${MY_P}.tar.gz"
KEYWORDS="~amd64"
S="${WORKDIR}/${MY_P}"

LICENSE="BSD-2 CDDL MIT"
SLOT="0"
IUSE="debug nls pam python test-suite"

DEPEND="
	net-libs/libtirpc:=
	sys-apps/util-linux
	sys-libs/zlib
	virtual/libudev:=
	dev-libs/openssl:0=
	pam? ( sys-libs/pam )
	python? (
		virtual/python-cffi[${PYTHON_USEDEP}]
	)
"

BDEPEND="app-alternatives/awk
	virtual/pkgconfig
	nls? ( sys-devel/gettext )
	python? (
		dev-python/setuptools[${PYTHON_USEDEP}]
	)
"

RDEPEND="${DEPEND}
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

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RESTRICT="test"

PATCHES=(
	"${FILESDIR}"/2.1.5-r2-dracut-non-root.patch
	"${FILESDIR}"/2.1.5-dracut-zfs-missing.patch
	"${FILESDIR}"/2.1.5-dracut-mount.patch
	"${FILESDIR}"/2.1.6-fgrep.patch
	"${FILESDIR}"/2.1.7-dracut-include-systemd-overrides.patch
	"${FILESDIR}"/2.1.7-systemd-zed-restart-always.patch
)

src_prepare() {
	default

	if use python; then
		pushd contrib/pyzfs >/dev/null || die
		distutils-r1_src_prepare
		popd >/dev/null || die
	fi

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
		--with-vendor=gentoo
		$(use_enable debug)
		$(use_enable nls)
		$(use_enable pam)
		$(use_enable python pyzfs)
		--disable-static
	)

	econf "${myconf[@]}"
}

src_compile() {
	default
	if use python; then
		pushd contrib/pyzfs >/dev/null || die
		distutils-r1_src_compile
		popd >/dev/null || die
	fi
}

src_install() {
	default

	gen_usr_ldscript -a nvpair uutil zfsbootenv zfs zfs_core zpool

	use pam && { rm -rv "${ED}/unwanted_files" || die ; }

	use test-suite || { rm -r "${ED}/usr/share/zfs" || die ; }

	dobashcomp contrib/bash_completion.d/zfs
	bashcomp_alias zfs zpool

	# strip executable bit from conf.d file
	fperms 0644 /etc/conf.d/zfs

	if use python; then
		pushd contrib/pyzfs >/dev/null || die
		distutils-r1_src_install
		popd >/dev/null || die
	fi

	# enforce best available python implementation
	python_setup
	python_fix_shebang "${ED}/bin"
}
