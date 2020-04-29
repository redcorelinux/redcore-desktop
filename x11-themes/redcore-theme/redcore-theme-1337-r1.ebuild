# Copyright 2015 Rogentos
# Distributed under the terms of the GNU General Public License v3

EAPI=6

inherit eutils git-r3

DESCRIPTION="Official Redcore Linux GTK theme"
HOMEPAGE="http://redcorelinux.org"

EGIT_BRANCH="master"
EGIT_REPO_URI="https://pagure.io/redcore/redcore-theme.git"

LICENSE="GPLv3"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE=""
RDEPEND="x11-themes/gtk-engines-murrine
	x11-themes/gtk-engines-unico"

src_install() {
	rm README.md
	dodir usr/share/themes
	insinto usr/share/themes
	doins -r *
}
