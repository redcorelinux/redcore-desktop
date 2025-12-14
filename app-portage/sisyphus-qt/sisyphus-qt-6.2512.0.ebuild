# Copyright 2016-2025 Redcore Linux Project
# Distributed under the terms of the GNU General Public License v2

EAPI=7

MY_PN="${PN/-qt/}"

PYTHON_COMPAT=( python3_{11..13} )

inherit python-single-r1 git-r3

DESCRIPTION="A simple portage python wrapper which works like other package managers(apt-get/yum/dnf)"
HOMEPAGE="http://redcorelinux.org"

EGIT_REPO_URI="https://gitlab.com/redcore/sisyphus.git"
EGIT_BRANCH="master"
EGIT_COMMIT="1cbf700cca1cf75e7dd36c3053313c87d8775805"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm64"
IUSE="qt5 qt6"

DEPEND="dev-lang/python[sqlite]
	~app-portage/sisyphus-${PV}"
RDEPEND="${DEPEND}
	app-misc/tmux
	qt5? ( $(python_gen_cond_dep '
		dev-python/pyqt5[gui,widgets,${PYTHON_USEDEP}]
	') )
	qt6? ( $(python_gen_cond_dep '
		dev-python/pyqt6[gui,widgets,${PYTHON_USEDEP}]
	') )"

src_install() {
	emake DESTDIR="${D}"/ install-gui

	# enforce the best available python implementation (GUI)
	python_setup
	if use qt5; then
		python_fix_shebang "${ED}"/usr/share/"${MY_PN}"/"${MY_PN}"-qt5.py
	else
		rm -rvf "${ED}"/usr/share/"${MY_PN}"/"${MY_PN}"-qt5.py
	fi

	if use qt6; then
		python_fix_shebang "${ED}"/usr/share/"${MY_PN}"/"${MY_PN}"-qt6.py
	else
		rm -rvf "${ED}"/usr/share/"${MY_PN}"/"${MY_PN}"-qt6.py
	fi
}
