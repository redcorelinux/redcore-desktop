# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils multilib toolchain-funcs

DESCRIPTION="NVIDIA Linux X11 Settings Utility"
HOMEPAGE="http://www.nvidia.com/"
SRC_URI="https://github.com/NVIDIA/nvidia-settings/archive/${PV}.tar.gz -> nvidia-settings-${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0/390132"
KEYWORDS="-* amd64"
IUSE="gtk3"

QA_PREBUILT=

COMMON_DEPEND="
	x11-libs/gtk+:2
	gtk3? ( x11-libs/gtk+:3 )
	x11-libs/libX11
	x11-libs/libXext
	x11-libs/libXxf86vm
	x11-libs/gdk-pixbuf[X]
	media-libs/mesa
	x11-libs/pango[X]
	x11-libs/libXv
	x11-libs/libXrandr
	dev-libs/glib:2
	dev-libs/jansson
	x11-libs/cairo
	>=x11-libs/libvdpau-1.0"

RDEPEND="${COMMON_DEPEND}
	x11-drivers/nvidia-drivers:${SLOT}"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	x11-base/xorg-proto"

src_prepare() {
	default
	eapply "${FILESDIR}"/nvidia-settings-linker.patch
}

src_compile() {
	emake -C src/ \
		AR="$(tc-getAR)" \
		CC="$(tc-getCC)" \
		DO_STRIP= \
		LD="$(tc-getCC)" \
		LIBDIR="$(get_libdir)" \
		NVLD="$(tc-getLD)" \
		NV_VERBOSE=1 \
		RANLIB="$(tc-getRANLIB)" \
		build-xnvctrl

	emake -C src/ \
		CC="$(tc-getCC)" \
		DO_STRIP= \
		GTK3_AVAILABLE=$(usex gtk3 1 0) \
		LD="$(tc-getCC)" \
		LIBDIR="$(get_libdir)" \
		NVLD="$(tc-getLD)" \
		NVML_ENABLED=0 \
		NV_USE_BUNDLED_LIBJANSSON=0 \
		NV_VERBOSE=1
}

src_install() {
	emake -C src/ \
		DESTDIR="${D}" \
		GTK3_AVAILABLE=$(usex gtk3 1 0) \
		LIBDIR="${D}/usr/$(get_libdir)" \
		NV_USE_BUNDLED_LIBJANSSON=0 \
		NV_VERBOSE=1 \
		PREFIX=/usr \
		DO_STRIP= \
		install

	insinto /usr/$(get_libdir)
	doins src/libXNVCtrl/libXNVCtrl.a

	insinto /usr/include/NVCtrl
	doins src/libXNVCtrl/*.h

	doicon doc/${PN}.png
	domenu ${FILESDIR}/${PN}.desktop

	dodoc doc/*.txt
}