# Copyright 2016-2018 Redcore Linux Project
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils git-r3

DESCRIPTION="Versatile Advanced Script for ISO and Latest Enchantments"
HOMEPAGE="https://redcorelinux.org"

EGIT_REPO_URI="https://pagure.io/redcore/vasile.git"
EGIT_BRANCH="master"
EGIT_COMMIT="4461a01202018c5120d19f6b997e402f85ee66cd"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64"
IUSE=""

DEPEND="sys-apps/gentoo-functions"
RDEPEND="${DEPEND}
	dev-libs/libisoburn
	dev-vcs/git
	sys-boot/grub:2
	sys-kernel/dkms
	sys-fs/mtools
	sys-fs/squashfs-tools"

src_install() {
	default
	dosym ../../usr/bin/"${PN}".sh usr/bin/"${PN}"
	dodir var/cache/packages
	dodir var/cache/distfiles
}
