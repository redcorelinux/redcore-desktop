# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit xdg-utils gnome2 pax-utils udev unpacker eapi7-ver

MAIN_PV="$(ver_cut 1-3)"
MY_PV="${MAIN_PV}"

KEYWORDS="~amd64"

VBOX_BUILD_ID="$(ver_cut 4)"
VBOX_PV="${MY_PV}-${VBOX_BUILD_ID}"
MY_P="VirtualBox-${VBOX_PV}-Linux"

EXTP_PV="${VBOX_PV}"
EXTP_PN="Oracle_VM_VirtualBox_Extension_Pack"
EXTP_P="${EXTP_PN}-${EXTP_PV}"

DESCRIPTION="Family of powerful x86 virtualization products for enterprise and home use"
HOMEPAGE="https://www.virtualbox.org/"
SRC_URI="amd64? ( https://download.virtualbox.org/virtualbox/${MY_PV}/${MY_P}_amd64.run )
	https://download.virtualbox.org/virtualbox/${MY_PV}/${EXTP_P}.vbox-extpack -> ${EXTP_P}.tar.gz"

LICENSE="GPL-2 PUEL"
SLOT="0"
IUSE=""
RESTRICT="mirror"

DEPEND="app-arch/unzip"

RDEPEND="
	!!app-emulation/virtualbox
	!!app-emulation/virtualbox-additions
	!!app-emulation/virtualbox-extpack-oracle
	!!app-emulation/virtualbox-guest-additions
	acct-group/vboxusers
	~app-emulation/virtualbox-modules-${MAIN_PV}
	dev-libs/expat
	dev-libs/glib
	dev-libs/libxml2
	media-libs/fontconfig
	media-libs/freetype
	media-libs/libpng
	media-libs/libsdl[X]
	sys-fs/lvm2
	x11-libs/libXcursor
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXft
	x11-libs/libXi
	x11-libs/libXinerama
	x11-libs/libXrandr
	x11-libs/libXrender
	x11-libs/libXau
	x11-libs/libX11
	x11-libs/libXt
	x11-libs/libXmu
	x11-libs/libSM
	x11-libs/libICE
	x11-libs/libXdmcp"

S="${WORKDIR}"

QA_PREBUILT="opt/VirtualBox/*"

src_unpack() {
	unpack_makeself ${MY_P}_${ARCH}.run
	unpack ./VirtualBox.tar.bz2

	mkdir "${S}"/${EXTP_PN} || die
	pushd "${S}"/${EXTP_PN} &>/dev/null || die
	unpack ${EXTP_P}.tar.gz
	popd &>/dev/null || die
}

src_configure() {
	:;
}

src_compile() {
	:;
}

src_install() {
	# create virtualbox configurations files
	insinto /etc/vbox
	newins "${FILESDIR}/${PN}-config" vbox.cfg

	newmenu "${FILESDIR}"/${PN}.desktop-2 ${PN}.desktop

	# set up symlinks (bug #572012)
	dosym ../../../../opt/VirtualBox/virtualbox.xml /usr/share/mime/packages/virtualbox.xml

	local size ico icofile
	for size in 16 24 32 48 64 72 96 128 256 ; do
		pushd "${S}"/icons/${size}x${size} &>/dev/null || die
		if [[ -f "virtualbox.png" ]] ; then
			doicon -s ${size} virtualbox.png
		fi
		for ico in hdd ova ovf vbox{,-extpack} vdi vdh vmdk ; do
			icofile="virtualbox-${ico}.png"
			if [[ -f "${icofile}" ]] ; then
				doicon -s ${size} ${icofile}
			fi
		done
		popd &>/dev/null || die
	done
	doicon -s scalable "${S}"/icons/scalable/virtualbox.svg
	insinto /usr/share/pixmaps
	newins "${S}"/icons/48x48/virtualbox.png ${PN}.png

	pushd "${S}"/${EXTP_PN} &>/dev/null || die
	insinto /opt/VirtualBox/ExtensionPacks/${EXTP_PN}
	doins -r linux.${ARCH}
	doins ExtPack* PXE-Intel.rom
	popd &>/dev/null || die
	rm -rf "${S}"/${EXTP_PN}

	insinto /opt/VirtualBox
	dodir /opt/bin

	doins UserManual.pdf
	doins -r additions

	doins kchmviewer VirtualBox.chm
	fowners root:vboxusers /opt/VirtualBox/kchmviewer
	fperms 0750 /opt/VirtualBox/kchmviewer

	rm -rf src rdesktop* deffiles install* routines.sh runlevel.sh \
		vboxdrv.sh VBox.sh VBox.png vboxnet.sh additions VirtualBox.desktop \
		VirtualBox.tar.bz2 LICENSE VBoxSysInfo.sh rdesktop* vboxwebsrv \
		webtest kchmviewer sdk VirtualBox.chm vbox-create-usb-node.sh \
		90-vbox-usb.fdi uninstall.sh vboxshell.py vboxdrv-pardus.py \
		VBoxPython*.so virtualbox.desktop

	doins -r * || die

	# create symlinks for working around unsupported $ORIGIN/.. in VBoxC.so (setuid)
	dosym ../VBoxVMM.so /opt/VirtualBox/components/VBoxVMM.so
	dosym ../VBoxRT.so /opt/VirtualBox/components/VBoxRT.so
	dosym ../VBoxDDU.so /opt/VirtualBox/components/VBoxDDU.so
	dosym ../VBoxXPCOM.so /opt/VirtualBox/components/VBoxXPCOM.so

	local each
	for each in VirtualBox{,VM} ; do
		fowners root:vboxusers /opt/VirtualBox/${each}
		fperms 0750 /opt/VirtualBox/VirtualBox
		fperms 4750 /opt/VirtualBox/VirtualBoxVM
		pax-mark -m "${ED%/}"/opt/VirtualBox/${each}
	done

	for each in VBox{Autostart,BalloonCtrl,BugReport,DTrace,VolInfo,Manage,SVC,XPCOMIPCD,Tunctl,TestOGL,ExtPackHelperApp} ; do
		fowners root:vboxusers /opt/VirtualBox/${each}
		fperms 0750 /opt/VirtualBox/${each}
		pax-mark -m "${ED%/}"/opt/VirtualBox/${each}
	done

	# VBoxNetAdpCtl and VBoxNetDHCP binaries need to be suid root in any case..
	for each in VBoxNet{AdpCtl,DHCP,NAT} ; do
		fowners root:vboxusers /opt/VirtualBox/${each}
		fperms 4750 /opt/VirtualBox/${each}
		pax-mark -m "${ED%/}"/opt/VirtualBox/${each}
	done

	# Hardened build: Mark selected binaries set-user-ID-on-execution
	for each in VBox{SDL,Headless} ; do
		fowners root:vboxusers /opt/VirtualBox/${each}
		fperms 4510 /opt/VirtualBox/${each}
		pax-mark -m "${ED%/}"/opt/VirtualBox/${each}
	done

	dosym ../VirtualBox/VBox.sh /opt/bin/VirtualBox
	dosym ../VirtualBox/VBox.sh /opt/bin/VBoxSDL

	exeinto /opt/VirtualBox
	newexe "${FILESDIR}/${PN}-3-wrapper" "VBox.sh"
	fowners root:vboxusers /opt/VirtualBox/VBox.sh
	fperms 0750 /opt/VirtualBox/VBox.sh

	dosym ../VirtualBox/VBox.sh /opt/bin/VBoxManage
	dosym ../VirtualBox/VBox.sh /opt/bin/VBoxVRDP
	dosym ../VirtualBox/VBox.sh /opt/bin/VBoxHeadless
	dosym ../VirtualBox/VBoxTunctl /opt/bin/VBoxTunctl

	# set an env-variable for 3rd party tools
	echo -n "VBOX_APP_HOME=/opt/VirtualBox" > "${T}/90virtualbox"
	doenvd "${T}/90virtualbox"

	local udevdir="$(get_udevdir)"
	insinto ${udevdir}/rules.d
	doins "${FILESDIR}"/10-virtualbox.rules
	sed "s@%UDEVDIR%@${udevdir}@" \
		-i "${ED%/}"${udevdir}/rules.d/10-virtualbox.rules || die
	# move udev scripts into ${udevdir} (bug #372491)
	mv "${ED%/}"/opt/VirtualBox/VBoxCreateUSBNode.sh "${ED%/}"${udevdir} || die
	fperms 0750 ${udevdir}/VBoxCreateUSBNode.sh
}

pkg_postinst() {
	xdg_icon_cache_update
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
	udevadm control --reload-rules && udevadm trigger --subsystem-match=usb
}

pkg_postrm() {
	xdg_icon_cache_update
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
}
