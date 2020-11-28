# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit bash-completion-r1 eutils linux-info systemd toolchain-funcs

DESCRIPTION="Generic initramfs generation tool"
HOMEPAGE="https://dracut.wiki.kernel.org"
SRC_URI="https://www.kernel.org/pub/linux/utils/boot/${PN}/${P}.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 ~arm ia64 ~mips ppc ~ppc64 sparc x86"
IUSE="+cryptsetup debug +device-mapper +lvm +microcode +splash +mdadm selinux"

# Tests need root privileges, bug #298014
RESTRICT="test"

COMMON_DEPEND=">=sys-apps/kmod-23[tools]
	virtual/pkgconfig
	virtual/udev
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
	)
	sys-kernel/dracutcfg
	"
RDEPEND="${COMMON_DEPEND}
	app-arch/cpio
	>=app-shells/bash-4.0:0
	sys-apps/coreutils[xattr(-)]
	|| (
		sys-apps/openrc[sysv-utils,selinux?]
		sys-apps/systemd[sysv-utils]
	)
	>=sys-apps/util-linux-2.21

	debug? ( dev-util/strace )
	selinux? (
		sec-policy/selinux-dracut
		sys-libs/libselinux
		sys-libs/libsepol
	)
	"
DEPEND="${COMMON_DEPEND}
	app-text/asciidoc
	app-text/docbook-xml-dtd:4.5
	>=app-text/docbook-xsl-stylesheets-1.75.2
	>=dev-libs/libxslt-1.1.26
	"

DOCS=( AUTHORS HACKING NEWS README README.generic README.kernel README.modules
	README.testsuite TODO )

QA_MULTILIB_PATHS="usr/lib/dracut/.*"

PATCHES=(
	"${FILESDIR}"/048-dracut-install-simplify-ldd-parsing-logic.patch
	"${FILESDIR}"/048-redcore-change-default-initramfs-name.patch
	"${FILESDIR}"/048-remove_JobRunningTimeoutSec.patch
	"${FILESDIR}"/048-sort-fixup-creating-early-microcode.patch
	"${FILESDIR}"/fix-bash-5.patch
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

src_install() {
	default

	local libdirs=( /$(get_libdir) /usr/$(get_libdir) )
	if [[ ${SYMLINK_LIB} = yes && $(get_libdir) != lib ]]; then
		# Preserve lib -> lib64 symlinks in initramfs
		libdirs+=( /lib /usr/lib )
	fi

	einfo "Setting libdirs to \"${libdirs[*]}\" ..."
	echo "libdirs=\"${libdirs[*]}\"" > "${T}/gentoo.conf" || die
	insinto "/usr/lib/dracut/dracut.conf.d"
	doins "${T}/gentoo.conf"

	insinto /etc/logrotate.d
	newins dracut.logrotate dracut

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
