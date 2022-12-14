# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python{2_7,3_8,3_9,3_10} )

inherit distutils-r1 git-r3

DESCRIPTION="Python library for downloading from http URLs"
HOMEPAGE="https://github.com/steveeJ/python-wget"

EGIT_REPO_URI="https://github.com/steveeJ/python-wget.git"
EGIT_BRANCH="master"

LICENSE="GPL"
SLOT="0"
KEYWORDS="amd64 arm64"
IUSE=""

RDEPEND=""
DEPEND="
	dev-python/setuptools[${PYTHON_USEDEP}]
"

S="${WORKDIR}/${PN}-${PV}"

python_install_all() {
	distutils-r1_python_install_all
}
