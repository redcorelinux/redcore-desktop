# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit eutils git-r3

DESCRIPTION="A simple portage wrapper which works like other package managers"
HOMEPAGE="http://redcorelinux.org"

EGIT_BRANCH=master
EGIT_REPO_URI="https://gitlab.com/redcore/sisyphus.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND=""
RDEPEND="app-portage/gentoolkit
	app-portage/portage-utils
	sys-apps/gentoo-functions
	sys-apps/portage"

src_install() {
	# create database and csv folders
	dodir /var/lib/${PN}/{csv,db}
	# install the backend
	dodir /usr/$(get_libdir)/${PN}
	insinto /usr/$(get_libdir)/${PN}
	doins ${S}/backend/libsisyphus.sh
	# install the cli frontend
	dobin frontend/cli/${PN}-cli
	dosym /usr/bin/${PN}-cli /usr/bin/${PN}
	# install the gui frontend
	#
	# 
	# work in progress
	# not finished yet
	#
	#
}
