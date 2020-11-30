# Copyright 2016-2020 Redcore Linux Project
# Distributed under the terms of the GNU General Public License v2

EAPI=6

MY_PN="${PN/-qt/}"

PYTHON_COMPAT=( python3_{6,7,8} )

inherit eutils python-r1 git-r3

DESCRIPTION="A simple portage python wrapper which works like other package managers(apt-get/yum/dnf)"
HOMEPAGE="http://redcorelinux.org"

EGIT_REPO_URI="https://gitlab.com/redcore/sisyphus.git"
EGIT_BRANCH="master"
EGIT_COMMIT="1b5d87dc8393295568f8f82a5d48fbc086f2caaf"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND="dev-lang/python[sqlite]"
RDEPEND="${DEPEND}
	app-misc/tmux
	app-portage/sisyphus
	dev-python/PyQt5[designer,gui,widgets,${PYTHON_USEDEP}]"

src_install() {
	emake DESTDIR=${D} install-gui

	# enforce the best available python implementation (CLI)
	python_setup
	python_fix_shebang "${ED}usr/share/${MY_PN}/${MY_PN}-gui.py"
}
