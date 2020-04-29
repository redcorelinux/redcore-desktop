# Copyright 2016-2018 Redcore Linux Project
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python3_{5,6,7} )

inherit eutils python-r1 git-r3

DESCRIPTION="A simple portage python wrapper which works like other package managers(apt-get/yum/dnf)"
HOMEPAGE="http://redcorelinux.org"

EGIT_REPO_URI="https://pagure.io/redcore/sisyphus.git"
EGIT_REPO_URI="https://gitlab.com/redcore/sisyphus.git"
EGIT_BRANCH="master"
EGIT_COMMIT="3e315edde07f7392fa40b353445d0bddb721e73f"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="+gui"

DEPEND="dev-lang/python[sqlite]"
RDEPEND="${DEPEND}
	app-misc/tmux
	app-portage/gentoolkit[${PYTHON_USEDEP}]
	app-portage/portage-utils
	dev-python/animation[${PYTHON_USEDEP}]
	dev-python/urllib3[${PYTHON_USEDEP}]
	dev-python/wget[${PYTHON_USEDEP}]
	sys-apps/portage[${PYTHON_USEDEP}]
	sys-apps/gentoo-functions
	gui? ( dev-python/PyQt5[designer,gui,widgets,${PYTHON_USEDEP}] )"

src_install() {
	default

	inject_libsisyphus() {
		python_moduleinto "$(python_get_sitedir)"
		python_domodule src/backend/libsisyphus.py
	}

	python_foreach_impl inject_libsisyphus

	dosym /usr/share/${PN}/${PN}-cli.py /usr/bin/${PN}
	keepdir var/lib/${PN}/{csv,db}

	dodir etc/${PN}
	insinto etc/${PN}
	doins ${FILESDIR}/mirrors.conf

	if ! use gui; then
		rm -rf ${ED}usr/bin/${PN}-gui
		rm -rf ${ED}usr/bin/${PN}-gui-pkexec
		rm -rf ${ED}usr/share/${PN}/${PN}-gui.py
		rm -rf ${ED}usr/share/${PN}/icon
		rm -rf ${ED}usr/share/${PN}/ui
		rm -rf ${ED}usr/share/applications
		rm -rf ${ED}usr/share/pixmaps
		rm -rf ${ED}usr/share/polkit-1
	fi
}
