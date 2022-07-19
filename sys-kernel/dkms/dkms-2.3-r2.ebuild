# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit eutils bash-completion-r1

DESCRIPTION="Dynamic Kernel Module Support"
SRC_URI="https://github.com/dell/dkms/archive/2.3.tar.gz -> ${P}.tar.gz"
HOMEPAGE="https://github.com/dell/dkms"
LICENSE="GPL-2"
DEPEND=""
RDEPEND="sys-apps/gentoo-functions"
KEYWORDS="amd64 arm64"
SLOT="0"

PATCHES=(
	"${FILESDIR}"/"${P}"-dont-touch-configs.patch
	"${FILESDIR}"/"${P}"-gentoo-functions.patch
	"${FILESDIR}"/"${P}"-systemd-service-fix.patch
	"${FILESDIR}"/"${P}"-redcore-makefile.patch
)

src_install() {
	emake DESTDIR=${D} install
	newinitd "${FILESDIR}"/dkms.initd dkms
}
