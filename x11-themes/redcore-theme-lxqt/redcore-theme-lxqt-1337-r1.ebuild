# Copyright 2015 Rogentos
# Distributed under the terms of the GNU General Public License v3

EAPI=6

inherit eutils git-r3

DESCRIPTION="Official Redcore Linux LXQT theme"
HOMEPAGE="http://redcorelinux.org"

EGIT_BRANCH="master"
EGIT_REPO_URI="https://pagure.io/redcore/redcore-theme-lxqt.git"

LICENSE="GPLv3"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE=""
RDEPEND=""

src_install() {
	rm README.md
	dodir usr/share/lxqt/themes
	insinto usr/share/lxqt/themes
	doins -r *
}
