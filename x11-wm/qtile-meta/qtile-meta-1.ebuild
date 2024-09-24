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

IUSE="+archiver discover +display-manager gtk +lximage networkmanager qt5 qt6 +screenshot +sddm +terminal"

RDEPEND="
	x11-misc/rofi
	x11-themes/kvantum
	archiver? ( app-arch/lxqt-archiver )
	discover? ( kde-plasma/discover )
	display-manager? (
		sddm? ( x11-misc/sddm )
		!sddm? ( x11-misc/lightdm )
	)
	gtk? ( lxde-base/lxappearance )
	lximage? ( media-gfx/lximage-qt )
	networkmanager? (
		net-misc/networkmanager
		gnome-extra/nm-applet
	)
	qt5? ( x11-misc/qt5ct )
	qt6? ( gui-apps/qt6ct )
	screenshot? ( media-gfx/flameshot )
	sddm? ( x11-misc/sddm )
	terminal? ( x11-terms/alacritty )
"
