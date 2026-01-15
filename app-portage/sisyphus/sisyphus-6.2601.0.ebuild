# Copyright 2016-2025 Redcore Linux Project
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{11..13} )

inherit python-single-r1 git-r3

DESCRIPTION="A simple portage python wrapper which works like other package managers(apt-get/yum/dnf)"
HOMEPAGE="http://redcorelinux.org"

EGIT_REPO_URI="https://gitlab.com/redcore/sisyphus.git"
EGIT_BRANCH="master"
EGIT_COMMIT="f054852f82f6d4959f1ad0e27168f0358c621148"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm64"
IUSE=""

DEPEND="dev-lang/python[sqlite]"
RDEPEND="${DEPEND}
	app-portage/portage-utils
	$(python_gen_cond_dep '
		app-portage/gentoolkit[${PYTHON_USEDEP}]
		dev-python/animation[${PYTHON_USEDEP}]
		dev-python/click[${PYTHON_USEDEP}]
		dev-python/colorama[${PYTHON_USEDEP}]
		dev-python/gitpython[${PYTHON_USEDEP}]
		dev-python/typer[${PYTHON_USEDEP}]
		dev-python/typing-extensions[${PYTHON_USEDEP}]
		dev-python/urllib3[${PYTHON_USEDEP}]
		sys-apps/portage[${PYTHON_USEDEP}]
	')
	sys-apps/gentoo-functions"

src_install() {
	emake DESTDIR="${D}"/ install-cli

	python_moduleinto "$(python_get_sitedir)"/"${PN}"
	python_domodule src/backend/*.py

	dosym /usr/share/"${PN}"/"${PN}"-cli.py /usr/bin/"${PN}"
	keepdir var/lib/"${PN}"/{csv,db}
	keepdir var/db/repos

	dodir etc/"${PN}"
	keepdir etc/"${PN}"
	insinto etc/"${PN}"
	doins "${FILESDIR}"/"${PN}".net_chk_addr.conf

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

	dodir etc/"${PN}"/news
	keepdir etc/"${PN}"/news

	# enforce the best available python implementation (CLI)
	python_setup
	python_fix_shebang "${ED}"/usr/share/"${PN}"/"${PN}"-cli.py
}

pkg_postinst() {
	# Take care of the etc-update for the user
	rm -rf "${EROOT}"/etc/"${PN}"/._cfg*
	rm -rf "${EROOT}"/etc/"${PN}"/news/._cfg*

	# Make sure portage sees the new mirror configuration file
	rm -rf "{EROOT}"/etc/"${PN}"/mirrors.conf

	if [[ $(uname -m) == "x86_64" ]] ; then
		ln -sf "${EROOT}"/etc/"${PN}"/"${PN}"-mirrors-amd64.conf "${EROOT}"/etc/"${PN}"/mirrors.conf
	elif [[ $(uname -m) == "aarch64" ]] ; then
		ln -sf "${EROOT}"/etc/"${PN}"/"${PN}"-mirrors-arm64.conf "${EROOT}"/etc/"${PN}"/mirrors.conf
	fi
}
