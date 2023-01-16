# Copyright 2016-2020 Redcore Linux Project
# Distributed under the terms of the GNU General Public License v2

EAPI=7

MY_PN="${PN/-qt/}"

PYTHON_COMPAT=( python3_{8,9,10} )

inherit eutils python-single-r1 git-r3

DESCRIPTION="A simple portage python wrapper which works like other package managers(apt-get/yum/dnf)"
HOMEPAGE="http://redcorelinux.org"

EGIT_REPO_URI="https://gitlab.com/redcore/sisyphus.git"
EGIT_BRANCH="master"
EGIT_COMMIT="5997105bebeb1f3ea15be1c9ee00e36daf5d534d"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm64"
IUSE=""

DEPEND="dev-lang/python[sqlite]
	~app-portage/sisyphus-${PV}"
RDEPEND="${DEPEND}
	app-misc/tmux
	$(python_gen_cond_dep '
		dev-python/PyQt5[designer,gui,widgets,${PYTHON_USEDEP}]
	')"

src_install() {
	emake DESTDIR="${D}"/ install-gui

	# enforce the best available python implementation (CLI)
	python_setup
	python_fix_shebang "${ED}"/usr/share/"${MY_PN}"/"${MY_PN}"-gui.py
}
