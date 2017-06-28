# Copyright 1999-2016 Gentoo Foundation 
# Distributed under the terms of the GNU General Public License v2 
# $Header: /dev-util/notepadqq-9999.ebuild,v 0.1 frostwork $ 

EAPI=5
inherit eutils qmake-utils git-r3

DESCRIPTION="Tool for creating bootable installation USB flash drives"
EGIT_REPO_URI="https://github.com/KaOSx/${PN}.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="+dialog"

RDEPEND=" 
	dev-qt/qtcore:5 
	dev-qt/qtgui:5
	dialog? ( kde-apps/kdialog ) 
"
DEPEND="${RDEPEND}"

src_configure() { 
   eqmake5 ImageWriter.pro 
}

src_install() { 
   make INSTALL_ROOT=${D} install || die 
}
