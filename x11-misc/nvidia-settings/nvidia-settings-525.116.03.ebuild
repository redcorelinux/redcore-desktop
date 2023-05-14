# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils multilib toolchain-funcs

DESCRIPTION="NVIDIA Linux X11 Settings Utility"
HOMEPAGE="http://www.nvidia.com/"
SRC_URI="https://github.com/NVIDIA/nvidia-settings/archive/refs/tags/${PV}.tar.gz -> nvidia-settings-${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="525"
KEYWORDS="-* amd64"
IUSE=""

QA_PREBUILT=

COMMON_DEPEND="
	x11-libs/gtk+:2
	x11-libs/gtk+:3
	x11-libs/libX11
	x11-libs/libXext
	x11-libs/libXxf86vm
	x11-libs/gdk-pixbuf-xlib
	media-libs/mesa
	x11-libs/pango[X]
	x11-libs/libXv
	x11-libs/libXrandr
	dev-libs/glib:2
	dev-libs/jansson
	x11-libs/cairo
	>=x11-libs/libvdpau-1.0"

RDEPEND="${COMMON_DEPEND}
	!!x11-misc/nvidia-settings:390
	!!x11-misc/nvidia-settings:470
	!!x11-misc/nvidia-settings:515
	~x11-drivers/nvidia-drivers-${PV}:${SLOT}"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	x11-base/xorg-proto"

src_prepare() {
	default
	eapply "${FILESDIR}"/"${PN}"-linker.patch
}


src_compile() {
	einfo "Building libXNVCtrl..."
	emake -C src/libXNVCtrl \
		DO_STRIP= \
		LIBDIR="$(get_libdir)" \
		NVLD="$(tc-getLD)" \
		NV_VERBOSE=1 \
		OUTPUTDIR=. \
		RANLIB="$(tc-getRANLIB)"

	einfo "Building nvidia-settings..."
	emake -C src/ \
		DO_STRIP= \
		GTK3_AVAILABLE=1 \
		LIBDIR="$(get_libdir)" \
		NVLD="$(tc-getLD)" \
		NVML_ENABLED=0 \
		NV_USE_BUNDLED_LIBJANSSON=0 \
		NV_VERBOSE=1 \
		OUTPUTDIR=.
}

src_install() {
	emake -C src/ \
		DESTDIR="${D}" \
		DO_STRIP= \
		GTK3_AVAILABLE=1 \
		LIBDIR="${D}/usr/$(get_libdir)" \
		NV_USE_BUNDLED_LIBJANSSON=0 \
		NV_VERBOSE=1 \
		OUTPUTDIR=. \
		PREFIX=/usr \
		install

	insinto /usr/$(get_libdir)
	doins src/libXNVCtrl/libXNVCtrl.a

	insinto /usr/include/NVCtrl
	doins src/libXNVCtrl/*.h

	doicon doc/${PN}.png || die
	domenu ${FILESDIR}/${PN}.desktop || die

	dodoc doc/*.txt

	rm -rvf ${D}usr/$(get_libdir)/libnvidia-gtk2.so.${PV}
}
