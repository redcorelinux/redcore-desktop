# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

DESCRIPTION="Solaris Porting Layer meta-package (Gentoo compatibility ebuild)"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64"
IUSE=""

DEPEND="~sys-fs/spl-utils-${PV}
	~sys-kernel/spl-dkms-${PV}"
RDEPEND=""
