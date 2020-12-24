# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

if [[ ${PV} = *9999* ]]; then
	EGIT_BRANCH="v241-stable"
	EGIT_REPO_URI="https://github.com/elogind/elogind.git"
	inherit git-r3
else
	SRC_URI="https://github.com/${PN}/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sparc ~x86"
fi

inherit linux-info meson pam udev xdg-utils

DESCRIPTION="The systemd project's logind, extracted to a standalone package"
HOMEPAGE="https://github.com/elogind/elogind"

LICENSE="CC0-1.0 LGPL-2.1+ public-domain"
SLOT="0"
IUSE="+acl audit debug doc +pam +policykit selinux"

BDEPEND="
	app-text/docbook-xml-dtd:4.2
	app-text/docbook-xml-dtd:4.5
	app-text/docbook-xsl-stylesheets
	dev-util/gperf
	dev-util/intltool
	virtual/pkgconfig
"
DEPEND="
	audit? ( sys-process/audit )
	sys-apps/util-linux
	sys-libs/libcap
	virtual/libudev:=
	acl? ( sys-apps/acl )
	pam? ( sys-libs/pam )
	selinux? ( sys-libs/libselinux )
"
RDEPEND="${DEPEND}
	!sys-apps/systemd
"
PDEPEND="
	sys-apps/dbus
	policykit? ( sys-auth/polkit )
"

DOCS=( README.md src/libelogind/sd-bus/GVARIANT-SERIALIZATION )

PATCHES=(
	"${FILESDIR}/${P}-nodocs.patch"
	"${FILESDIR}/${PN}-241.4-broken-test.patch" # bug 699116
)

pkg_setup() {
	local CONFIG_CHECK="~CGROUPS ~EPOLL ~INOTIFY_USER ~SIGNALFD ~TIMERFD"

	use kernel_linux && linux-info_pkg_setup
}

src_prepare() {
	default
	xdg_environment_reset
}

src_configure() {
	local rccgroupmode="$(grep rc_cgroup_mode ${EPREFIX}/etc/rc.conf | cut -d '"' -f 2)"
	local cgroupmode="legacy"

	if [[ "xhybrid" = "x${rccgroupmode}" ]] ; then
		cgroupmode="hybrid"
	elif [[ "xunified" = "x${rccgroupmode}" ]] ; then
		cgroupmode="unified"
	fi

	local emesonargs=(
		-Ddocdir="${EPREFIX}/usr/share/doc/${PF}"
		-Dhtmldir="${EPREFIX}/usr/share/doc/${PF}/html"
		-Dpamlibdir=$(getpam_mod_dir)
		-Dudevrulesdir="${EPREFIX}$(get_udevdir)"/rules.d
		--libdir="${EPREFIX}"/usr/$(get_libdir)
		-Drootlibdir="${EPREFIX}"/$(get_libdir)
		-Drootlibexecdir="${EPREFIX}"/$(get_libdir)/elogind
		-Drootprefix="${EPREFIX}/"
		-Dbashcompletiondir="${EPREFIX}/usr/share/bash-completion/completions"
		-Dman=auto
		-Dsmack=true
		-Dcgroup-controller=openrc
		-Ddefault-hierarchy=${cgroupmode}
		-Ddefault-kill-user-processes=false
		-Dacl=$(usex acl true false)
		-Daudit=$(usex audit true false)
		--buildtype $(usex debug debug release)
		-Dhtml=$(usex doc auto false)
		-Dpam=$(usex pam true false)
		-Dselinux=$(usex selinux true false)
		-Dutmp=$(usex elibc_musl false true)
	)

	meson_src_configure
}

src_install() {
	DOCS+=( src/libelogind/sd-bus/GVARIANT-SERIALIZATION )

	meson_src_install

	newinitd "${FILESDIR}"/${PN}.init ${PN}

	sed -e "s/@libdir@/$(get_libdir)/" "${FILESDIR}"/${PN}.conf.in > ${PN}.conf || die
	newconfd ${PN}.conf ${PN}

	rm -rf ${ED}/lib/udev/rules.d/73-seat-late.rules
}
