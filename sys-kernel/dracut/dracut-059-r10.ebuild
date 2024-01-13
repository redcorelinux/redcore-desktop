# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit bash-completion-r1 systemd toolchain-funcs

KEYWORDS="~alpha amd64 arm arm64 ~hppa ~ia64 ~loong ~mips ppc ppc64 ~riscv sparc x86"
SRC_URI="https://github.com/dracutdevs/dracut/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"

DESCRIPTION="Generic initramfs generation tool"
HOMEPAGE="https://github.com/dracutdevs/dracut/wiki"

LICENSE="GPL-2"
SLOT="0"
IUSE="+cryptsetup +device-mapper +lvm +microcode +splash +mdadm selinux test"

RESTRICT="!test? ( test )"

COMMON_DEPEND="
	cryptsetup? (
		sys-fs/cryptsetup
	)
	device-mapper? (
		sys-fs/lvm2
	)
	lvm? (
		sys-fs/lvm2
	)
	microcode? (
		sys-firmware/intel-microcode
		sys-kernel/linux-firmware
	)
	splash? (
		sys-boot/plymouth
	)
	mdadm? (
		sys-fs/mdadm
	)"

RDEPEND="${COMMON_DEPEND}
	app-alternatives/cpio
	>=app-shells/bash-4.0:0
	sys-apps/coreutils[xattr(-)]
	>=sys-apps/kmod-23[tools]
	|| (
		>=sys-apps/sysvinit-2.87-r3
		sys-apps/openrc[sysv-utils(-),selinux?]
		sys-apps/systemd[sysv-utils]
	)
	>=sys-apps/util-linux-2.21
	virtual/pkgconfig
	virtual/udev

	elibc_musl? ( sys-libs/fts-standalone )
	selinux? (
		sec-policy/selinux-dracut
		sys-libs/libselinux
		sys-libs/libsepol
	)
"
DEPEND="${COMMON_DEPEND}
	>=sys-apps/kmod-23
	elibc_musl? ( sys-libs/fts-standalone )
"

BDEPEND="
	app-text/asciidoc
	app-text/docbook-xml-dtd:4.5
	>=app-text/docbook-xsl-stylesheets-1.75.2
	>=dev-libs/libxslt-1.1.26
	virtual/pkgconfig
"

QA_MULTILIB_PATHS="usr/lib/dracut/.*"

PATCHES=(
	"${FILESDIR}"/gentoo-ldconfig-paths-r1.patch
	"${FILESDIR}"/gentoo-network-r1.patch
	"${FILESDIR}"/059-kernel-install-uki.patch
	"${FILESDIR}"/059-uefi-split-usr.patch
	"${FILESDIR}"/059-uki-systemd-254.patch
	"${FILESDIR}"/059-gawk.patch
	"${FILESDIR}"/dracut-059-dmsquash-live.patch
	"${FILESDIR}"/059-systemd-pcrphase.patch
	"${FILESDIR}"/059-systemd-executor.patch
	"${FILESDIR}"/dracut-059-install-new-systemd-hibernate-resume.service.patch
	"${FILESDIR}"/059-redcore-change-default-initramfs-name.patch
)

src_configure() {
	local myconf=(
		--prefix="${EPREFIX}/usr"
		--sysconfdir="${EPREFIX}/etc"
		--bashcompletiondir="$(get_bashcompdir)"
		--systemdsystemunitdir="$(systemd_get_systemunitdir)"
	)

	tc-export CC PKG_CONFIG

	echo ./configure "${myconf[@]}"
	./configure "${myconf[@]}" || die

	if [[ ${PV} != 9999 && ! -f dracut-version.sh ]] ; then
		# Source tarball from github doesn't include this file
		echo "DRACUT_VERSION=${PV}" > dracut-version.sh || die
	fi
}

src_test() {
	if [[ ${EUID} != 0 ]]; then
		# Tests need root privileges, bug #298014
		ewarn "Skipping tests: Not running as root."
	elif [[ ! -w /dev/kvm ]]; then
		ewarn "Skipping tests: Unable to access /dev/kvm."
	else
		emake -C test check
	fi
}

src_install() {
	local DOCS=(
		AUTHORS
		NEWS.md
		README.md
		docs/README.cross
		docs/README.generic
		docs/README.kernel
		docs/SECURITY.md
	)

	default

	docinto html
	dodoc dracut.html
}

_dracut_initramfs_regen() {
	if [ -x $(which dracut) ]; then
		dracut -N -f --no-hostonly-cmdline
	fi
}

pkg_postinst() {
	if [ $(stat -c %d:%i /) == $(stat -c %d:%i /proc/1/root/.) ]; then
		_dracut_initramfs_regen
	fi
}

