# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGIT_BRANCH="master"
EGIT_REPO_URI="https://gitlab.com/redcore/redcore-live.git"

inherit eutils systemd git-r3

DESCRIPTION="Redcore Linux live scripts"
HOMEPAGE="http://redcorelinux.org"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND=""
RDEPEND=""

src_install() {
	emake DESTDIR="${D}" SYSTEMD_UNITDIR="$(systemd_get_unitdir)" \
		install || die
}

pkg_postrm() {
	for service in "redcorelive.service" ; do
		find "${ROOT}etc/systemd/system" -name "$service" -delete
	done
}
