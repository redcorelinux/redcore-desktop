# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit eutils gnome2-utils xdg-utils systemd

# Major version
MV="${PV/\.*}"
MY_PN="${PN}${MV}"
DESCRIPTION="All-In-One Solution for Remote Access and Support over the Internet"
HOMEPAGE="https://www.teamviewer.com"
SRC_URI="amd64? ( https://dl.tvcdn.de/download/linux/version_13x/${PN}_${PV}_amd64.tar.xz ) "

IUSE="system-xdg systemd"

LICENSE="TeamViewer"
SLOT="${MV}"
KEYWORDS="amd64 x86"

RESTRICT="bindist mirror"

RDEPEND="
	dev-qt/qtgui:5
	dev-qt/qtwebkit:5
	dev-qt/qtx11extras:5
	dev-qt/qtwidgets:5
	dev-qt/qtnetwork:5
	dev-qt/qtdeclarative:5
	dev-qt/qtdbus:5
	media-libs/alsa-lib
	x11-libs/libICE
	x11-libs/libSM
	x11-libs/libX11
	x11-libs/libXau
	x11-libs/libXdamage
	x11-libs/libXdmcp
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXrandr
	x11-libs/libXtst"

QA_PREBUILT="opt/teamviewer${MV}/*"

S="${WORKDIR}/teamviewer/tv_bin/"

src_prepare() {
	sed \
		-e "s/@TVV@/${MV}/g" \
		"${FILESDIR}"/${PN}d.init > "${T}"/init || die
	sed \
		-e "s:/opt/teamviewer:/opt/teamviewer${MV}:g" \
		"script//${PN}d.service" > "${T}/${PN}d.service" || die
	sed \
		-e "s/@TVV@/${PV}/g" \
		-e "s/@TVMV@/${MV}/g" \
		"${FILESDIR}"/${PN}.sh > "${T}"/sh || die
}

src_install () {
	local destdir="/opt/${MY_PN}"

	# install executables wrapper
	exeinto "/opt/bin"
	newexe "${T}/sh" "${MY_PN}"
	dosym "${destdir}"/tv_bin/TeamViewer /opt/bin/"${MY_PN}"

	# install daemon binary and scripts
	exeinto "${destdir}/tv_bin"
	doexe "${PN}"d
	doexe TeamViewer
	doexe "${PN}"-config
	newinitd "${T}/init" "${PN}d${MV}"
	newconfd "${FILESDIR}/${PN}d.conf" "${PN}d${MV}"
	
	if use systemd ; then
		systemd_newunit "${T}/${PN}d.service" "${PN}d${MV}.service"
	fi

	insinto "${destdir}/tv_bin"
	doins -r desktop
	doins -r resources
	rm "${S}"/script/teamviewerd.DEB.conf || die
	rm "${S}"/script/teamviewerd.RHEL.conf || die
	rm "${S}"/script/teamviewerd.RPM.conf || die
	doins -r script

	# teamviewer can use system/not system xdg utils
	if ! use system-xdg ; then
		doins -r xdg-utils
	fi

	# set up logdir
	keepdir /var/log/"${MY_PN/}"
	dosym /var/log/"${MY_PN}" "/opt/${MY_PN}/logfiles"

	# set up config dir
	keepdir /etc/"${MY_PN}"
	dosym /etc/"${MY_PN}" "/opt/${MY_PN}/config"

	newicon -s 48 desktop/"${PN}"_48.png "${MY_PN}.png"
	#dodoc ../doc/linux_FAQ_{EN,DE}.txt
	make_desktop_entry "${MY_PN}" "TeamViewer ${MV}" "${MY_PN}"
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	gnome2_icon_cache_update
	xdg_desktop_database_update

	elog "TeamViewer from upstream uses an overly-complicated set of bash"
	elog "scripts to start the program.  This has been simplified for Gentoo"
	elog "The end-user client requires running the accompanying daemon,"
	elog "available via init-scripts."
}

pkg_postrm() {
	gnome2_icon_cache_update
	xdg_desktop_database_update
}
