# Copyright 2016-2020 Redcore Linux Project
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python3_{6,7,8} )

inherit eutils python-single-r1 git-r3

DESCRIPTION="A simple portage python wrapper which works like other package managers(apt-get/yum/dnf)"
HOMEPAGE="http://redcorelinux.org"

EGIT_REPO_URI="https://gitlab.com/redcore/sisyphus.git"
EGIT_BRANCH="master"
EGIT_COMMIT="74ab4e42aa24eea172cd03c6fa4c15250fff4a48"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="qt5"

DEPEND="dev-lang/python[sqlite]"
RDEPEND="${DEPEND}
	app-portage/portage-utils
	$(python_gen_cond_dep '
		app-portage/gentoolkit[${PYTHON_MULTI_USEDEP}]
		dev-python/animation[${PYTHON_MULTI_USEDEP}]
		dev-python/GitPython[${PYTHON_MULTI_USEDEP}]
		dev-python/typer[${PYTHON_MULTI_USEDEP}]
		dev-python/urllib3[${PYTHON_MULTI_USEDEP}]
		dev-python/wget[${PYTHON_MULTI_USEDEP}]
		sys-apps/portage[${PYTHON_MULTI_USEDEP}]
	')
	sys-apps/gentoo-functions"
PDEPEND="qt5? ( ~app-portage/sisyphus-qt-${PV} )"

src_install() {
	emake DESTDIR="${D}" install-cli

	python_moduleinto "$(python_get_sitedir)"/"${PN}"
	python_domodule src/backend/*.py

	dosym /usr/share/"${PN}"/"${PN}"-cli.py /usr/bin/"${PN}"
	keepdir var/lib/"${PN}"/{csv,db}

	dodir etc/"${PN}"
	insinto etc/"${PN}"
	doins "${FILESDIR}"/mirrors.conf

	doins "${FILESDIR}"/sisyphus-custom.env.conf
	doins "${FILESDIR}"/sisyphus-custom.make.conf
	doins "${FILESDIR}"/sisyphus-custom.package.accept_keywords
	doins "${FILESDIR}"/sisyphus-custom.package.env
	doins "${FILESDIR}"/sisyphus-custom.package.license
	doins "${FILESDIR}"/sisyphus-custom.package.mask
	doins "${FILESDIR}"/sisyphus-custom.package.unmask
	doins "${FILESDIR}"/sisyphus-custom.package.use

	# enforce the best available python implementation (CLI)
	python_setup
	python_fix_shebang "${ED}"usr/share/"${PN}"/"${PN}"-cli.py
}

pkg_postinst() {
	# Take care of the etc-update for the user
	if [ -e "${EROOT}"etc/"${PN}"/._cfg0000_mirrors.conf ] ; then
		rm -rf "${EROOT}"etc/._cfg0000_mirros.conf
	fi

	for i in sisyphus-custom.{env.conf,make.conf,package.{accept_keywords,env,license,mask,unmask,use}}; do
		if [ -e "${EROOT}"etc/"${PN}"/._cfg000_"$i" ] ; then
			rm -rf "${EROOT}"etc/"${PN}"/._cfg000_"$i"
		fi
	done
}
