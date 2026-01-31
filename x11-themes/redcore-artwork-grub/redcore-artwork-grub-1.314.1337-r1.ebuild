# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3

DESCRIPTION="Redcore Linux GRUB2 Images"
HOMEPAGE="http://redcorelinux.org"

EGIT_BRANCH="master"
EGIT_REPO_URI="https://codeberg.org/redcore/boot-core.git"

LICENSE="CCPL-Attribution-ShareAlike-3.0"
SLOT="0"

KEYWORDS="amd64 x86"
IUSE=""
RDEPEND=""

S="${WORKDIR}/${P}"

src_install () {
	dodir usr/share/grub/themes
	insinto usr/share/grub/themes
	doins -r "${S}"/cdroot/boot/grub/themes/redcore
}
