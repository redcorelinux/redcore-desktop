# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils git-r3

DESCRIPTION="Icon theme following the Google's material design specifications"
HOMEPAGE="https://gitlab.com/bionel/bionel-icons"

EGIT_BRANCH="master"
EGIT_REPO_URI="https://gitlab.com/bionel/bionel-icons.git"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

S="${WORKDIR}/${P}"

src_install() {
	dodir usr/share/icons
	insinto usr/share/icons
	doins -r material-icons/*
}
