# Copyright 2016-2020 Redcore Linux Project
# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python3_{8,9,10} )

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
	<dev-python/click-8[${PYTHON_USEDEP}]
"

PATCHES=( "${FILESDIR}"/"${PN}"-avoid-python-dephell-dependency.patch )

python_install_all() {
	distutils-r1_python_install_all
}
