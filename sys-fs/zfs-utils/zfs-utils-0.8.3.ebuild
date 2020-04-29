# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DISTUTILS_OPTIONAL=1
PYTHON_COMPAT=( python{2_7,3_{6,7,8}} )

inherit bash-completion-r1 flag-o-matic distutils-r1 toolchain-funcs udev

MY_PN="zfs"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Userland utilities for ZFS Linux kernel module"
HOMEPAGE="https://zfsonlinux.org/"

SRC_URI="https://github.com/zfsonlinux/${MY_PN}/releases/download/${MY_P}/${MY_P}.tar.gz"
KEYWORDS="~amd64"

LICENSE="BSD-2 CDDL MIT"
SLOT="0"
IUSE="debug python test-suite static-libs"

COMMON_DEPEND="
	${PYTHON_DEPS}
	net-libs/libtirpc
	sys-apps/util-linux[static-libs?]
	sys-libs/zlib[static-libs(+)?]
	virtual/awk
	python? (
		virtual/python-cffi[${PYTHON_USEDEP}]
	)
"

BDEPEND="${COMMON_DEPEND}
	virtual/pkgconfig
	python? (
		dev-python/setuptools[${PYTHON_USEDEP}]
	)
"

RDEPEND="${COMMON_DEPEND}
	!=sys-apps/grep-2.13*
	!sys-fs/zfs-fuse
	!prefix? ( virtual/udev )
	sys-fs/udev-init-scripts
	test-suite? (
		sys-apps/util-linux
		sys-devel/bc
		sys-block/parted
		sys-fs/lsscsi
		sys-fs/mdadm
		sys-process/procps
		virtual/modutils
	)
"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RESTRICT="test"

S="${WORKDIR}/${MY_P}"

PATCHES=( "${FILESDIR}/bash-completion-sudo.patch" )

src_prepare() {
	default
	# Update paths
	sed -e "s|/sbin/lsmod|/bin/lsmod|" \
		-e "s|/usr/bin/scsi-rescan|/usr/sbin/rescan-scsi-bus|" \
		-e "s|/sbin/parted|/usr/sbin/parted|" \
		-i scripts/common.sh.in || die

	if use python; then
		pushd contrib/pyzfs >/dev/null || die
		distutils-r1_src_prepare
		popd >/dev/null || die
	fi
}

src_configure() {
	local myconf=(
		--bindir="${EPREFIX}/bin"
		--disable-systemd
		--enable-sysvinit
		--localstatedir="${EPREFIX}/var"
		--sbindir="${EPREFIX}/sbin"
		--with-config=user
		--with-dracutdir="${EPREFIX}/usr/lib/dracut"
		--with-udevdir="$(get_udevdir)"
		$(use_enable debug)
		$(use_enable python pyzfs)
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

	gen_usr_ldscript -a uutil nvpair zpool zfs zfs_core

	use test-suite || rm -rf "${ED}/usr/share/zfs"

	dobashcomp contrib/bash_completion.d/zfs
	bashcomp_alias zfs zpool

	if use python; then
		pushd contrib/pyzfs >/dev/null || die
		distutils-r1_src_install
		popd >/dev/null || die
	fi

	# enforce best available python implementation
	python_setup
	python_fix_shebang "${ED}/bin"
}
