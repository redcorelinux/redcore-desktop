# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGIT_BRANCH="master"
EGIT_REPO_URI="https://pagure.io/redcore/redcore-live.git"

inherit eutils git-r3

DESCRIPTION="Redcore Linux live scripts"
HOMEPAGE="http://redcorelinux.org"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND=""
RDEPEND=""

src_install() {
	default
}

pkg_prerm() {
	if [ "$(rc-config list boot | grep redcorelive)" != "" ]; then
		"${ROOT}"/sbin/rc-update del redcorelive boot > /dev/null 2>&1
	fi
}
