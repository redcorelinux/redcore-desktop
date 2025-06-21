# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10..12} )

inherit distutils-r1

DESCRIPTION="Tools for terminal-based wait animations"
HOMEPAGE="https://github.com/bprinty/animation"
SRC_URI="https://github.com/bprinty/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL"
SLOT="0"
KEYWORDS="amd64 arm64"
IUSE=""
RESTRICT="test"

RDEPEND=""
DEPEND="
	dev-python/setuptools[${PYTHON_USEDEP}]
"

S="${WORKDIR}/${PN}-${PV}"

python_install_all() {
	distutils-r1_python_install_all
}
