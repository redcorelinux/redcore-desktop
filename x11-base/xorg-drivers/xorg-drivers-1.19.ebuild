# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

DESCRIPTION="Meta package containing deps on all xorg drivers (dummy package)"
HOMEPAGE="https://www.gentoo.org/"
SRC_URI=""

LICENSE="metapackage"
SLOT="0"
KEYWORDS="alpha amd64 arm ~arm64 ~hppa ~ia64 ~mips ppc ppc64 ~s390 ~sh sparc x86 ~amd64-fbsd ~x86-fbsd ~amd64-linux ~arm-linux ~x86-linux"

IUSE=""

PDEPEND="!x11-drivers/xf86-input-citron
	!x11-drivers/xf86-video-cyrix
	!x11-drivers/xf86-video-impact
	!x11-drivers/xf86-video-ivtv
	!x11-drivers/xf86-video-nsc
	!x11-drivers/xf86-video-sunbw2

	!<=x11-drivers/xf86-video-ark-0.7.5
	!<=x11-drivers/xf86-video-newport-0.2.4

	!<x11-drivers/xf86-input-evdev-2.10.4
	!<x11-drivers/xf86-input-joystick-1.6.3
	!<x11-drivers/xf86-input-libinput-0.20.0
	!<x11-drivers/xf86-input-wacom-0.34.0
	!<x11-drivers/xf86-video-amdgpu-1.2.0
	!<x11-drivers/xf86-video-ati-7.8.0
	!<x11-drivers/xf86-video-chips-1.2.7
	!<x11-drivers/xf86-video-glint-1.2.9
	!<x11-drivers/xf86-video-i740-1.3.6
	!<x11-drivers/xf86-video-intel-2.99.917_p20160122
	!<x11-drivers/xf86-video-mga-1.6.5
	!<x11-drivers/xf86-video-nouveau-1.0.13
	!<x11-drivers/xf86-video-nv-2.1.21
	!<x11-drivers/xf86-video-omap-0.4.5
	!<x11-drivers/xf86-video-r128-6.10.2
	!<x11-drivers/xf86-video-savage-2.3.9
	!<x11-drivers/xf86-video-siliconmotion-1.7.9
	!<x11-drivers/xf86-video-sis-0.10.9
	!<x11-drivers/xf86-video-sisusb-0.9.7
	!<x11-drivers/xf86-video-sunleo-1.2.2
	!<x11-drivers/xf86-video-tdfx-1.4.7
	!<x11-drivers/xf86-video-trident-1.3.8
	!<x11-drivers/xf86-video-virtualbox-5.1.14
	!<x11-drivers/xf86-video-vmware-13.2.1
"
