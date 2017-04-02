# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit eutils git-r3

DESCRIPTION="A simple portage wrapper which works like other package managers"
HOMEPAGE="http://redcorelinux.org"

EGIT_BRANCH=master
EGIT_REPO_URI="https://gitlab.com/redcore/epkg.git"
EGIT_COMMIT="32cbd03bed60e17c14c8b7012e8051fc27edda21"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND=""
RDEPEND="app-portage/gentoolkit
	app-portage/portage-utils
	sys-apps/gentoo-functions
	sys-apps/portage"

src_install() {
	dobin epkg
	dodir /var/lib/epkg/{csv,db}
	dodir /usr/$(get_libdir)/${PN}
	insinto /usr/$(get_libdir)/${PN}
	doins ${S}/libepkg
}
