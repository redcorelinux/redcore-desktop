# Copyright 2016-2025 Redcore Linux Project
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{11..13} )

inherit desktop git-r3 python-single-r1 systemd

DESCRIPTION="System Upgrade Watchdog Service"
HOMEPAGE="http://redcorelinux.org"

EGIT_REPO_URI="https://gitlab.com/redcore/hermes.git"
EGIT_BRANCH="redcore"
EGIT_COMMIT="5f019e43071abf305fabc7c2550d9fff702fa50f"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}
	>=app-portage/sisyphus-6.2512.0
	dev-libs/dbus-glib
	dev-libs/glib[introspection]
	dev-libs/gobject-introspection
	$(python_gen_cond_dep '
		dev-python/dbus-python[${PYTHON_USEDEP}]
		dev-python/pygobject[${PYTHON_USEDEP}]
		dev-python/pyqt6[dbus,gui,widgets,${PYTHON_USEDEP}]
	')
	sys-apps/dbus"

src_install() {
	dobin src/systray-app/hermes.py

	insopts -m 755
	insinto /usr/libexec
	doins src/daemon/hermesd.py

	insopts -m 644
	doicon src/icon/hermes-light.png
	doicon src/icon/hermes-dark.png
	domenu src/menu/org.redcorelinux.hermes.desktop

	insinto /etc/dbus-1/system.d
	doins src/dbus/org.redcorelinux.hermesd.conf

	insinto /etc/logrotate.d
	doins src/logrotate/hermes

	newinitd src/init/hermesd-openrc hermesd
	systemd_newunit src/init/hermesd-systemd.service hermesd.service

	python_setup
	python_fix_shebang "${ED}"/usr/bin/"${PN}".py
	python_fix_shebang "${ED}"/usr/libexec/"${PN}"d.py
}
