# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="RC init files for starting display and login managers"
HOMEPAGE="https://wiki.gentoo.org/wiki/Project:X11"

LICENSE="GPL-2"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sparc ~x86 ~amd64-linux ~x86-linux"
SLOT="0"

S="${FILESDIR}"

RDEPEND="
	sys-apps/gentoo-functions
	!<=sys-apps/sysvinit-2.98
	!<=x11-apps/xinit-1.4.1
	!<=x11-base/xorg-server-1.20.10-r10
"

src_install() {
	newinitd "${FILESDIR}"/display-manager-setup.initd display-manager-setup
	newinitd "${FILESDIR}"/display-manager.initd display-manager
	newconfd "${FILESDIR}"/display-manager.confd display-manager
	exeinto /usr/bin
	doexe "${FILESDIR}"/startDM
	# backwards compatibility
	dosym "${ESYSROOT}"/usr/bin/startDM /etc/X11/startDM.sh
}

pkg_postinst() {
	# Redcore Linux tweak : automatically migrate all users
	"${ROOT}"/sbin/rc-update del xdm default > /dev/null 2>&1
	"${ROOT}"/sbin/rc-update add display-manager default > /dev/null 2>&1
}
