# Copyright 2016-2020 Redcore Linux Project
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python3_{6,7,8} )

inherit eutils python-r1 git-r3

DESCRIPTION="A simple portage python wrapper which works like other package managers(apt-get/yum/dnf)"
HOMEPAGE="http://redcorelinux.org"

EGIT_REPO_URI="https://gitlab.com/redcore/sisyphus.git"
EGIT_BRANCH="master"
EGIT_COMMIT="02a67877e808bf2f3cf637bcc5694907ae6c2f00"

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
	dev-python/GitPython[${PYTHON_USEDEP}]
	dev-python/typer[${PYTHON_USEDEP}]
	dev-python/urllib3[${PYTHON_USEDEP}]
	dev-python/wget[${PYTHON_USEDEP}]
	sys-apps/portage[${PYTHON_USEDEP}]
	sys-apps/gentoo-functions
	gui? ( dev-python/PyQt5[designer,gui,widgets,${PYTHON_USEDEP}] )"

PATCHES=( "${FILESDIR}/a23accad55705278cb19592c4af785dd182f36b7.patch" )

src_install() {
	default

	inject_libsisyphus() {
		python_moduleinto "$(python_get_sitedir)"/"${PN}"
		python_domodule src/backend/*.py
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

	# enforce the best available python implementation (CLI)
	python_setup
	python_fix_shebang "${ED}usr/share/${PN}/${PN}-cli.py"

	# enforce the best available python implementation (GUI)
	if use gui; then
		python_setup
		python_fix_shebang "${ED}usr/share/${PN}/${PN}-gui.py"
	fi
}
