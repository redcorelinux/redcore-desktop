# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit bash-completion-r1 linux-info optfeature systemd toolchain-funcs

KEYWORDS="~alpha amd64 arm arm64 hppa ~ia64 ~loong ~mips ppc ppc64 ~riscv sparc x86"
SRC_URI="https://www.kernel.org/pub/linux/utils/boot/${PN}/${P}.tar.xz"

DESCRIPTION="Generic initramfs generation tool"
HOMEPAGE="https://dracut.wiki.kernel.org"

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
	app-arch/cpio
	>=app-shells/bash-4.0:0
	sys-apps/coreutils[xattr(-)]
	>=sys-apps/kmod-23[tools]
	|| (
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
	"${FILESDIR}"/056-redcore-change-default-initramfs-name.patch
	"${FILESDIR}"/056-musl.patch
	"${FILESDIR}"/056-fix-lvm-add-missing-grep-requirement.patch
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

	if linux-info_get_any_version && linux_config_exists; then
		ewarn ""
		ewarn "If the following test report contains a missing kernel"
		ewarn "configuration option, you should reconfigure and rebuild your"
		ewarn "kernel before booting image generated with this Dracut version."
		ewarn ""

		local CONFIG_CHECK="~BLK_DEV_INITRD ~DEVTMPFS"

		# Kernel configuration options descriptions:
		local ERROR_DEVTMPFS='CONFIG_DEVTMPFS: "Maintain a devtmpfs filesystem to mount at /dev" '
		ERROR_DEVTMPFS+='is missing and REQUIRED'
		local ERROR_BLK_DEV_INITRD='CONFIG_BLK_DEV_INITRD: "Initial RAM filesystem and RAM disk '
		ERROR_BLK_DEV_INITRD+='(initramfs/initrd) support" is missing and REQUIRED'

		check_extra_config
		echo
	else
		ewarn ""
		ewarn "Your kernel configuration couldn't be checked."
		ewarn "Please check manually if following options are enabled:"
		ewarn ""
		ewarn "  CONFIG_BLK_DEV_INITRD"
		ewarn "  CONFIG_DEVTMPFS"
		ewarn ""
	fi
}
