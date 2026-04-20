# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Meta ebuild for Qtile, a hackable tiling window manager written in Python"
HOMEPAGE="https://qtile.org/"

if [[ ${PV} != 9999 ]]; then
	KEYWORDS="~amd64"
fi

LICENSE="metapackage"
SLOT="0"

IUSE="+archiver +desktop-portal discover +display-manager +editor +extras +gtk +imgview +launcher +networkmanager +notifications +policykit +pulseaudio +qt5 +qt6 +screenshot +sddm +terminal +wallpaper +wayland +X"

RDEPEND="
	x11-wm/qtile
	archiver? ( app-arch/lxqt-archiver )
	desktop-portal? ( gui-libs/xdg-desktop-portal-wlr )
	discover? ( kde-plasma/discover )
	display-manager? (
		sddm? ( x11-misc/sddm )
		!sddm? ( x11-misc/lightdm )
	)
	editor? ( app-editors/featherpad )
	extras? ( x11-wm/qtile-extras )
	gtk? ( lxde-base/lxappearance )
	imgview? ( media-gfx/qimgv )
	launcher? ( x11-misc/rofi )
	networkmanager? (
		net-misc/networkmanager
		gnome-extra/nm-applet
	)
	notifications? ( x11-misc/dunst )
	policykit? ( || (
		kde-plasma/polkit-kde-agent
		gnome-extra/polkit-gnome
		)
	)
	pulseaudio? ( media-sound/pavucontrol-qt )
	qt5? ( x11-misc/qt5ct )
	qt6? ( gui-apps/qt6ct )
	screenshot? ( media-gfx/flameshot )
	sddm? ( x11-misc/sddm )
	terminal? ( x11-terms/alacritty )
	wallpaper? (
		X? ( media-gfx/feh )
		wayland? ( gui-apps/swaybg )
	)
	X? ( x11-misc/picom )
"
