# Copyright 2016-2020 Redcore Linux Project
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{10..12} )

inherit python-single-r1 git-r3

DESCRIPTION="A simple portage python wrapper which works like other package managers(apt-get/yum/dnf)"
HOMEPAGE="http://redcorelinux.org"

EGIT_REPO_URI="https://gitlab.com/redcore/sisyphus.git"
EGIT_BRANCH="master"
EGIT_COMMIT="e327ad76cfd12c8d70b8f9bee5f2b86c975ed073"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm64"
IUSE="qt5"

DEPEND="dev-lang/python[sqlite]"
RDEPEND="${DEPEND}
	app-portage/portage-utils
	$(python_gen_cond_dep '
		app-portage/gentoolkit[${PYTHON_USEDEP}]
		dev-python/animation[${PYTHON_USEDEP}]
		dev-python/GitPython[${PYTHON_USEDEP}]
		dev-python/typer[${PYTHON_USEDEP}]
		dev-python/typing-extensions[${PYTHON_USEDEP}]
		dev-python/urllib3[${PYTHON_USEDEP}]
		sys-apps/portage[${PYTHON_USEDEP}]
	')
	sys-apps/gentoo-functions"
PDEPEND="qt5? ( ~app-portage/${PN}-qt-${PV} )"

src_install() {
	emake DESTDIR="${D}"/ install-cli

	python_moduleinto "$(python_get_sitedir)"/"${PN}"
	python_domodule src/backend/*.py

	dosym /usr/share/"${PN}"/"${PN}"-cli.py /usr/bin/"${PN}"
	keepdir var/lib/"${PN}"/{csv,db}

	dodir etc/"${PN}"
	insinto etc/"${PN}"
	doins "${FILESDIR}"/"${PN}"-mirrors-amd64.conf
	doins "${FILESDIR}"/"${PN}"-mirrors-arm64.conf

	doins "${FILESDIR}"/"${PN}".build-env.conf
	doins "${FILESDIR}"/"${PN}".make-conf.conf
	doins "${FILESDIR}"/"${PN}".make-opts.conf
	doins "${FILESDIR}"/"${PN}".package-keywords.conf
	doins "${FILESDIR}"/"${PN}".package-env.conf
	doins "${FILESDIR}"/"${PN}".package-license.conf
	doins "${FILESDIR}"/"${PN}".package-mask.conf
	doins "${FILESDIR}"/"${PN}".package-unmask.conf
	doins "${FILESDIR}"/"${PN}".package-use.conf

	# enforce the best available python implementation (CLI)
	python_setup
	python_fix_shebang "${ED}"/usr/share/"${PN}"/"${PN}"-cli.py
}

pkg_postinst() {
	# Take care of the etc-update for the user
	rm -rf "${EROOT}"/etc/"${PN}"/._cfg*

	# Make sure portage sees the new mirror configuration file
	rm -rf "{EROOT}"/etc/"${PN}"/mirrors.conf

	if [[ $(uname -m) == "x86_64" ]] ; then
		ln -sf "${EROOT}"/etc/"${PN}"/"${PN}"-mirrors-amd64.conf "${EROOT}"/etc/"${PN}"/mirrors.conf
	elif [[ $(uname -m) == "aarch64" ]] ; then
		ln -sf "${EROOT}"/etc/"${PN}"/"${PN}"-mirrors-arm64.conf "${EROOT}"/etc/"${PN}"/mirrors.conf
	fi
}
