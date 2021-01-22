# Copyright 2016-2020 Redcore Linux Project
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python3_{6,7,8} )

inherit eutils python-r1 git-r3

DESCRIPTION="A simple portage python wrapper which works like other package managers(apt-get/yum/dnf)"
HOMEPAGE="http://redcorelinux.org"

EGIT_REPO_URI="https://gitlab.com/redcore/sisyphus.git"
EGIT_BRANCH="master"
EGIT_COMMIT="9163df2c61b1b79cb14a4358e304b31756384077"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="qt5"

DEPEND="dev-lang/python[sqlite]
	qt5? ( app-portage/sisyphus-qt )"
RDEPEND="dev-lang/python[sqlite]
	app-portage/gentoolkit[${PYTHON_USEDEP}]
	app-portage/portage-utils
	dev-python/animation[${PYTHON_USEDEP}]
	dev-python/GitPython[${PYTHON_USEDEP}]
	dev-python/typer[${PYTHON_USEDEP}]
	dev-python/urllib3[${PYTHON_USEDEP}]
	dev-python/wget[${PYTHON_USEDEP}]
	sys-apps/portage[${PYTHON_USEDEP}]
	sys-apps/gentoo-functions"

src_install() {
	emake DESTDIR=${D} install-cli

	inject_backend() {
		python_moduleinto "$(python_get_sitedir)"/"${PN}"
		python_domodule src/backend/*.py
	}

	python_foreach_impl inject_backend

	dosym /usr/share/${PN}/${PN}-cli.py /usr/bin/${PN}
	keepdir var/lib/${PN}/{csv,db}

	dodir etc/${PN}
	insinto etc/${PN}
	doins ${FILESDIR}/mirrors.conf

	# enforce the best available python implementation (CLI)
	python_setup
	python_fix_shebang "${ED}usr/share/${PN}/${PN}-cli.py"
}
