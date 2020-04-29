# Copyright 1999-2016 Gentoo Foundation 
# Distributed under the terms of the GNU General Public License v2 

EAPI=6
inherit eutils qmake-utils

DESCRIPTION="Monitor Radeon GPU parameters and switch power profiles"
HOMEPAGE="https://github.com/marazmista/radeon-profile"
SRC_URI="https://github.com/marazmista/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

RDEPEND="dev-qt/qtcore:5
	dev-qt/qtgui:5
	dev-qt/qtwidgets:5
	dev-qt/qtcharts:5
	x11-libs/libdrm
	x11-libs/libXrandr
	x11-libs/libxkbcommon
"
DEPEND="${RDEPEND}"

S=${WORKDIR}/${P}/${PN}

src_prepare() {
	default
	sed -i "s/Categories\=System\;Monitor\;HardwareSettings\;TrayIcon\;/Categories\=System\;/g" extra/${PN}.desktop
}

src_configure() { 
	eqmake5	${PN}.pro 
}

src_install() { 
	dodir usr/bin
	exeinto usr/bin
	doexe ${PN}
	doexe ${FILESDIR}/${PN}-pkexec
	dodir usr/share/applications
	insinto usr/share/applications
	doins extra/${PN}.desktop
	dodir usr/share/polkit-1/actions
	insinto usr/share/polkit-1/actions
	doins ${FILESDIR}/org.redcorelinux.radeon-profile.policy
	doicon extra/${PN}.png

	sed -i "s/Exec=radeon-profile/Exec=radeon-profile-pkexec/g" "${D}"usr/share/applications/${PN}.desktop
	sed -i "s/Categories=System;/Categories=System;Settings;/g" "${D}"usr/share/applications/${PN}.desktop
}
