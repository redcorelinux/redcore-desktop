# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Meta package containing deps on all xorg drivers (dummy package)"
HOMEPAGE="https://www.gentoo.org/"
SRC_URI=""

LICENSE="metapackage"
SLOT="0"
KEYWORDS="amd64 arm64"


PDEPEND="
	!x11-drivers/xf86-input-citron
	!x11-drivers/xf86-video-apm
	!x11-drivers/xf86-video-ark
	!x11-drivers/xf86-video-chips
	!x11-drivers/xf86-video-cirrus
	!x11-drivers/xf86-video-cyrix
	!x11-drivers/xf86-video-i128
	!x11-drivers/xf86-video-i740
	!x11-drivers/xf86-video-impact
	!x11-drivers/xf86-video-mach64
	!x11-drivers/xf86-video-neomagic
	!x11-drivers/xf86-video-newport
	!x11-drivers/xf86-video-nsc
	!x11-drivers/xf86-video-rendition
	!x11-drivers/xf86-video-s3
	!x11-drivers/xf86-video-s3virge
	!x11-drivers/xf86-video-savage
	!x11-drivers/xf86-video-sis
	!x11-drivers/xf86-video-sisusb
	!x11-drivers/xf86-video-sunbw2
	!x11-drivers/xf86-video-suncg14
	!x11-drivers/xf86-video-suncg3
	!x11-drivers/xf86-video-suncg6
	!x11-drivers/xf86-video-sunffb
	!x11-drivers/xf86-video-sunleo
	!x11-drivers/xf86-video-suntcx
	!x11-drivers/xf86-video-tga
	!x11-drivers/xf86-video-trident
	!x11-drivers/xf86-video-tseng
	!<x11-drivers/xf86-input-evdev-2.10.4
"
