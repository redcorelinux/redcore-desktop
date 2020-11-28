# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils user

DESCRIPTION="Redcore Linux Samba configuration files"
HOMEPAGE="https://redcorelinux.org"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

S=${FILESDIR}

src_install() {
	dodir etc/samba
	insinto etc/samba
	newins redcore-smb.conf smb.conf
	keepdir var/lib/samba/usershare
}

pkg_preinst() {
	enewgroup smbshare
}

pkg_postinst() {
	chown root:smbshare /var/lib/samba/usershare
	chmod 1770 /var/lib/samba/usershare
}
