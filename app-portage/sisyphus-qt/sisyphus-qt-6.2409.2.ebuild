# Copyright 2016-2020 Redcore Linux Project
# Distributed under the terms of the GNU General Public License v2

EAPI=7

MY_PN="${PN/-qt/}"

PYTHON_COMPAT=( python3_{10..12} )

inherit python-single-r1 git-r3

DESCRIPTION="A simple portage python wrapper which works like other package managers(apt-get/yum/dnf)"
HOMEPAGE="http://redcorelinux.org"

EGIT_REPO_URI="https://gitlab.com/redcore/sisyphus.git"
EGIT_BRANCH="master"
EGIT_COMMIT="69cba5b0c4695197100bb8e2454c9e7622cfb1b2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm64"
IUSE="qt5 qt6"

DEPEND="dev-lang/python[sqlite]
	~app-portage/sisyphus-${PV}"
RDEPEND="${DEPEND}
	app-misc/tmux
	qt5? ( $(python_gen_cond_dep '
		dev-python/PyQt5[designer,gui,widgets,${PYTHON_USEDEP}]
	') )
	qt6? ( $(python_gen_cond_dep '
		dev-python/PyQt6[designer,gui,widgets,${PYTHON_USEDEP}]
	') )"

src_install() {
	emake DESTDIR="${D}"/ install-gui

	# enforce the best available python implementation (GUI)
	python_setup
	if use qt5; then
		python_fix_shebang "${ED}"/usr/share/"${MY_PN}"/"${MY_PN}"-qt5.py
	fi

	if use qt6; then
		python_fix_shebang "${ED}"/usr/share/"${MY_PN}"/"${MY_PN}"-qt6.py
	fi
}