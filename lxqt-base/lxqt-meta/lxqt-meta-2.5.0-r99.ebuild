# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PV="$(ver_cut 1-2)"

DESCRIPTION="Meta ebuild for LXQt, the Lightweight Desktop Environment"
HOMEPAGE="https://lxqt-project.org/"

if [[ ${PV} != 9999 ]]; then
	KEYWORDS="~amd64"
fi

LICENSE="metapackage"
SLOT="0"

IUSE="
	+about admin +archiver clip +desktop-portal discover +display-manager +filemanager gtk
	+icons +lximage networkmanager nls +openbox +policykit powermanagement +processviewer
	qt5 qt6 +screenshot +sddm ssh-askpass +sudo +terminal +trash wayland +window-manager
"

REQUIRED_USE="trash? ( filemanager )"

RDEPEND="
	>=lxqt-base/lxqt-config-${MY_PV}*
	=lxqt-base/lxqt-globalkeys-${MY_PV}*
	=lxqt-base/lxqt-menu-data-${MY_PV}*
	=lxqt-base/lxqt-notificationd-${MY_PV}*
	=lxqt-base/lxqt-panel-${MY_PV}*
	=lxqt-base/lxqt-runner-${MY_PV}*
	=lxqt-base/lxqt-session-${MY_PV}*
	virtual/ttf-fonts
	x11-terms/xterm
	=x11-themes/lxqt-themes-${MY_PV}*
	x11-themes/redcore-theme-lxqt
	about? ( =lxqt-base/lxqt-about-${MY_PV}* )
	admin? ( =lxqt-base/lxqt-admin-${MY_PV}* )
	archiver? ( >=app-arch/lxqt-archiver-1.5 )
	clip? ( =gui-apps/lxqt-clip-${MY_PV}* )
	desktop-portal? ( >=gui-libs/xdg-desktop-portal-lxqt-1.5 )
	discover? ( kde-plasma/discover )
	display-manager? (
		sddm? ( gui-apps/sddm )
		!sddm? ( x11-misc/lightdm )
	)
	filemanager? ( =x11-misc/pcmanfm-qt-${MY_PV}* )
	gtk? ( lxde-base/lxappearance )
	icons? ( kde-frameworks/breeze-icons:6 )
	lximage? ( =media-gfx/lximage-qt-${MY_PV}* )
	networkmanager? (
		net-misc/networkmanager
		gnome-extra/nm-applet
	)
	nls? ( dev-qt/qttranslations:6 )
	policykit? ( =lxqt-base/lxqt-policykit-${MY_PV}* )
	powermanagement? ( =lxqt-base/lxqt-powermanagement-${MY_PV}* )
	processviewer? ( >=x11-misc/qps-2.14 )
	qt5? ( x11-misc/qt5ct )
	qt6? ( gui-apps/qt6ct )
	screenshot? ( >=x11-misc/screengrab-3.3 )
	sddm? ( gui-apps/sddm )
	ssh-askpass? ( =lxqt-base/lxqt-openssh-askpass-${MY_PV}* )
	sudo? ( =lxqt-base/lxqt-sudo-${MY_PV}* )
	terminal? ( =x11-terms/qterminal-${MY_PV}* )
	trash? ( gnome-base/gvfs )
	wayland? ( lxqt-base/lxqt-wayland-session )
	window-manager? (
		wayland? ( gui-wm/labwc )
		!wayland? (
			openbox? (
				x11-wm/openbox
				x11-misc/obconf
			)
		)
	)
"
