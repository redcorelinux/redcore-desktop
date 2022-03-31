# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit eutils multilib-minimal

DESCRIPTION="Legacy NetworkManager glib and util libraries"
HOMEPAGE="https://wiki.gnome.org/Projects/NetworkManager"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~ia64 ~ppc ~ppc64 ~sparc ~x86"
IUSE="gnutls +nss"
REQUIRED_USE="|| ( nss gnutls )"
RESTRICT="test"
SRC_URI="https://download.gnome.org/sources/NetworkManager/1.18/NetworkManager-${PV}.tar.xz"

DEPEND="
	>=sys-apps/dbus-1.2[${MULTILIB_USEDEP}]
	>=dev-libs/dbus-glib-0.100[${MULTILIB_USEDEP}]
	>=dev-libs/glib-2.40:2[${MULTILIB_USEDEP}]
	net-libs/libndp[${MULTILIB_USEDEP}]
	sys-apps/util-linux[${MULTILIB_USEDEP}]
	>=virtual/libudev-175:=[${MULTILIB_USEDEP}]
	nss? ( >=dev-libs/nss-3.11:=[${MULTILIB_USEDEP}] )
	!nss? ( gnutls? (
		dev-libs/libgcrypt:0=[${MULTILIB_USEDEP}]
		>=net-libs/gnutls-2.12:=[${MULTILIB_USEDEP}] ) )
"

RDEPEND="
	${DEPEND}
	!<net-misc/networkmanager-1.19
"

BDEPEND="
	>=dev-util/intltool-0.40
	virtual/pkgconfig
"

S="${WORKDIR}/NetworkManager-${PV}"

multilib_src_configure() {
	local myconf=(
		--disable-bluez5-dun
		--disable-concheck
		--disable-json-validation
		--disable-more-asserts
		--disable-more-logging
		--disable-ovs
		--disable-polkit
		--disable-polkit-agent
		--disable-ppp
		--disable-qt
		--disable-rpath
		--disable-teamdctl
		--disable-wifi
		--enable-introspection=no
		--enable-more-warnings=no
		--enable-vala=no
		--with-consolekit=no
		--with-crypto=$(usex nss gnutls)
		--with-dbus-sys-dir=/etc/dbus-1/system.d
		--with-dhclient=no
		--with-dhcpcanon=no
		--with-dhcpcd=no
		--with-ebpf=no
		--with-libnm-glib
		--with-libpsl=no
		--with-netconfig=no
		--with-nmcli=no
		--with-nmtui=no
		--without-iwd
		--without-libaudit
		--without-modem-manager-1
		--without-ofono
		--without-resolvconf
		--without-wext
		--with-selinux=no
		--with-session-tracking=no
		--with-suspend-resume=upower
		--with-systemd-journal=no
		--with-systemd-logind=no
		--with-valgrind=no
	)
	ECONF_SOURCE="${S}" econf "${myconf[@]}"
}

multilib_src_install() {
	dolib.so libnm-{glib,util}/.libs/libnm-*.so*[0-9]
}
