# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

PYTHON_COMPAT=( python3_4 )

inherit eutils git-r3 python-r1

DESCRIPTION="A simple portage python wrapper which works like other package managers(apt-get/yum/dnf)"
HOMEPAGE="http://redcorelinux.org"

EGIT_BRANCH=master
EGIT_REPO_URI="https://gitlab.com/redcore/sisyphus.git"
EGIT_COMMIT="b9e09c0b0b05934cad526711a51c4cbf63cc6070"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="+gui"

DEPEND="dev-lang/python:3.4[sqlite]"
RDEPEND="${DEPEND}
	app-portage/gentoolkit[${PYTHON_USEDEP}]
	dev-python/animation[${PYTHON_USEDEP}]
	dev-python/urllib3[${PYTHON_USEDEP}]
	sys-apps/portage[${PYTHON_USEDEP}]
	gui? ( dev-python/PyQt5[designer,gui,widgets,${PYTHON_USEDEP}] )"

src_install() {
	default
	dosym /usr/bin/${PN}-cli.py /usr/bin/${PN}
	dodir /var/lib/${PN}/{csv,db}
	if ! use gui; then
		rm -rf ${ED}usr/bin/${PN}-gui
		rm -rf ${ED}usr/bin/${PN}-gui-pkexec
		rm -rf ${ED}usr/share/${PN}/*py
		rm -rf ${ED}usr/share/${PN}/icon
		rm -rf ${ED}usr/share/${PN}/ui
		rm -rf ${ED}usr/share/applications
		rm -rf ${ED}usr/share/pixmaps
		rm -rf ${ED}usr/share/polkit-1
	fi
}
