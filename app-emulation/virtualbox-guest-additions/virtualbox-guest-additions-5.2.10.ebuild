# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils systemd user toolchain-funcs

MY_PV="${PV/beta/BETA}"
MY_PV="${MY_PV/rc/RC}"
MY_P=VirtualBox-${MY_PV}
DESCRIPTION="VirtualBox kernel modules and user-space tools for Gentoo guests"
HOMEPAGE="https://www.virtualbox.org/"
SRC_URI="https://download.virtualbox.org/virtualbox/${MY_PV}/${MY_P}.tar.bz2
	https://dev.gentoo.org/~polynomial-c/virtualbox/patchsets/virtualbox-5.1.30-patches-02.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64"
IUSE="X"

RDEPEND="
	X? ( x11-apps/xrandr
		x11-apps/xrefresh
		x11-libs/libXmu
		x11-libs/libX11
		x11-libs/libXt
		x11-libs/libXext
		x11-libs/libXau
		x11-libs/libXdmcp
		x11-libs/libSM
		x11-libs/libICE )
	sys-apps/dbus
	~sys-kernel/virtualbox-guest-dkms-${PV}
	!!x11-drivers/xf86-input-virtualbox
	!x11-drivers/xf86-video-virtualbox
"
DEPEND="
	${RDEPEND}
	>=dev-util/kbuild-0.1.9998.3127
	>=dev-lang/yasm-0.6.2
	sys-devel/bin86
	sys-libs/pam
	sys-power/iasl
	x11-base/xorg-proto
"
PDEPEND="
	X? ( x11-drivers/xf86-video-vboxvideo )
"
BUILD_TARGETS="all"
BUILD_TARGET_ARCH="${ARCH}"

S="${WORKDIR}/${MY_P}"

pkg_setup() {
	enewgroup vboxguest
	enewuser vboxguest -1 /bin/sh /dev/null vboxguest
	enewgroup vboxsf
}

src_unpack() {
	unpack ${A}
	cd "${S}"
	rm -rf kBuild/bin tools
}

src_prepare() {
	pushd "${WORKDIR}" &>/dev/null || die
	eapply "${FILESDIR}"/vboxguest-4.1.0-log-use-c99.patch
	popd &>/dev/null || die

	cp "${FILESDIR}/${PN}-5-localconfig" LocalConfig.kmk || die
	use X || echo "VBOX_WITH_X11_ADDITIONS :=" >> LocalConfig.kmk

	for vboxheader in {product,revision,version}-generated.h ; do
		for mdir in vbox{guest,sf} ; do
			ln -sf "${S}"/out/linux.${ARCH}/release/${vboxheader} \
				"${WORKDIR}/${mdir}/${vboxheader}"
		done
	done

	sed -e '/^check_gcc$/d' -i configure || die

	rm "${WORKDIR}/patches/011_virtualbox-5.1.30-sysmacros.patch" || die
	eapply "${WORKDIR}/patches"

	eapply_user
}

src_configure() {
	local cmd=(
		./configure
		--nofatal
		--disable-xpcom
		--disable-sdl-ttf
		--disable-pulse
		--disable-alsa
		--with-gcc="$(tc-getCC)"
		--with-g++="$(tc-getCXX)"
		--target-arch=${ARCH}
		--with-linux="${KV_OUT_DIR}"
		--build-headless
	)
	echo "${cmd[@]}"
	"${cmd[@]}" || die "configure failed"
	source ./env.sh
	export VBOX_GCC_OPT="${CFLAGS} ${CPPFLAGS}"
}

src_compile() {
	MAKE="kmk" \
	emake TOOL_YASM_AS=yasm \
	VBOX_ONLY_ADDITIONS=1 \
	KBUILD_VERBOSE=2
}

src_install() {
	cd "${S}"/out/linux.${ARCH}/release/bin/additions || die

	insinto /sbin
	newins mount.vboxsf mount.vboxsf
	fperms 4755 /sbin/mount.vboxsf

	newinitd "${FILESDIR}"/${PN}-8.initd ${PN}

	insinto /usr/sbin/
	newins VBoxService vboxguest-service
	fperms 0755 /usr/sbin/vboxguest-service

	insinto /usr/bin
	doins VBoxControl
	fperms 0755 /usr/bin/VBoxControl

	if use X ; then
		doins VBoxClient
		fperms 0755 /usr/bin/VBoxClient

		pushd "${S}"/src/VBox/Additions/x11/Installer &>/dev/null \
			|| die
		newins 98vboxadd-xclient VBoxClient-all
		fperms 0755 /usr/bin/VBoxClient-all
		popd &>/dev/null || die
	fi

	local udev_rules_dir="/lib/udev/rules.d"
	dodir ${udev_rules_dir}
	echo 'KERNEL=="vboxguest", OWNER="vboxguest", GROUP="vboxguest", MODE="0660"' \
		>> "${D}/${udev_rules_dir}/60-virtualbox-guest-additions.rules" \
		|| die
	echo 'KERNEL=="vboxuser", OWNER="vboxguest", GROUP="vboxguest", MODE="0660"' \
		>> "${D}/${udev_rules_dir}/60-virtualbox-guest-additions.rules" \
		|| die

	insinto /etc/xdg/autostart
	doins "${FILESDIR}"/vboxclient.desktop
	
	insinto /usr/share/doc/${PF}
	doins "${FILESDIR}"/xorg.conf.vbox

	systemd_dounit "${FILESDIR}/${PN}.service"
}
