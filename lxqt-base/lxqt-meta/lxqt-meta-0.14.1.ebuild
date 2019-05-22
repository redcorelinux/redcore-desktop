# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

DESCRIPTION="Meta ebuild for LXQt, the Lightweight Desktop Environment"
HOMEPAGE="http://lxqt.org/"

LICENSE="metapackage"
SLOT="0"
KEYWORDS="amd64"
IUSE="+about +admin +branding +compton +filemanager +gtk +icons +sddm +lximage minimal +oxygen +policykit
	+powermanagement +ssh-askpass sudo"
REQUIRED_USE="oxygen? ( icons )"
DEPEND="!!lxqt-base/lxqt-common"

RDEPEND="${DEPEND}
	>=lxde-base/lxmenu-data-0.1.2
	>=lxde-base/lxappearance-0.5.5
	>=lxqt-base/lxqt-themes-0.14.0
	~lxqt-base/lxqt-config-${PV}
	~lxqt-base/lxqt-globalkeys-${PV}
	~lxqt-base/lxqt-notificationd-${PV}
	~lxqt-base/lxqt-panel-${PV}
	~lxqt-base/lxqt-runner-${PV}
	~lxqt-base/lxqt-session-${PV}
	virtual/ttf-fonts
	about? ( ~lxqt-base/lxqt-about-${PV} )
	admin? ( ~lxqt-base/lxqt-admin-${PV} )
	branding? ( x11-themes/redcore-theme-lxqt )
	compton? ( x11-misc/compton x11-misc/compton-conf )
	filemanager? ( >=x11-misc/pcmanfm-qt-${PV} )
	gtk? ( dev-qt/qt5-styleplugins
		x11-libs/gtk+:2 )
	!gtk? ( >=lxqt-base/lxqt-qtplugin-0.14.0 )
	icons? ( oxygen? ( kde-frameworks/oxygen-icons )
		!oxygen? ( virtual/freedesktop-icon-theme ) )
	sddm? ( x11-misc/sddm )
	lximage? ( media-gfx/lximage-qt )
	!minimal? ( x11-wm/openbox
		x11-misc/obconf-qt )
	policykit? ( ~lxqt-base/lxqt-policykit-${PV}
		|| ( sys-auth/consolekit[policykit(-)]
			sys-apps/systemd[policykit(-)]
			sys-auth/elogind[policykit(-)] ) )
	powermanagement? ( ~lxqt-base/lxqt-powermanagement-${PV} )
	ssh-askpass? ( ~lxqt-base/lxqt-openssh-askpass-${PV} )
	sudo? ( ~lxqt-base/lxqt-sudo-${PV} )"

# Note: we prefer kde-frameworks/oxygen-icons over other icon sets, as the initial
# install expects oxygen icons, until the user specifies otherwise (bug 543380)

S="${WORKDIR}"
