# Copyright 2016-2023 Redcore Linux Project
# Distributed under the terms of the GNU General Public License v2

EAPI=8
DISTUTILS_USE_PEP517=flit

PYTHON_COMPAT=( python3_{9..11} )

inherit distutils-r1

DESCRIPTION="Build great CLIs. Easy to code. Based on Python type hints"
HOMEPAGE="https://typer.tiangolo.com/"
SRC_URI="https://github.com/tiangolo/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE=""

DEPEND="
	dev-python/setuptools[${PYTHON_USEDEP}]
"
RDEPEND="
	<dev-python/click-8.1.0[${PYTHON_USEDEP}]
	>=dev-python/click-8.0.0[${PYTHON_USEDEP}]
	dev-python/typing-extensions[${PYTHON_USEDEP}]
"

distutils_enable_tests pytest

python_install_all() {
	distutils-r1_python_install_all
}
