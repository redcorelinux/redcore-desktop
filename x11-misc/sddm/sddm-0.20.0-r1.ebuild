# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

SRC_URI="https://github.com/${PN}/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
KEYWORDS="~amd64 ~arm ~arm64 ~loong ~ppc64 ~riscv ~x86"

QTMIN=5.15.2
inherit cmake linux-info systemd tmpfiles

DESCRIPTION="Simple Desktop Display Manager"
HOMEPAGE="https://github.com/sddm/sddm"

LICENSE="GPL-2+ MIT CC-BY-3.0 CC-BY-SA-3.0 public-domain"
SLOT="0"
IUSE="+branding +elogind systemd test"

REQUIRED_USE="^^ ( elogind systemd )"
RESTRICT="!test? ( test )"

COMMON_DEPEND="
	acct-group/sddm
	acct-user/sddm
	>=dev-qt/qtcore-${QTMIN}:5
	>=dev-qt/qtdbus-${QTMIN}:5
	>=dev-qt/qtdeclarative-${QTMIN}:5
	>=dev-qt/qtgui-${QTMIN}:5
	>=dev-qt/qtnetwork-${QTMIN}:5
	sys-libs/pam
	x11-libs/libXau
	x11-libs/libxcb:=
	branding? ( x11-themes/redcore-theme-sddm )
	elogind? ( sys-auth/elogind[pam] )
	systemd? ( sys-apps/systemd:=[pam] )
	!systemd? ( sys-power/upower )
"
DEPEND="${COMMON_DEPEND}
	test? ( >=dev-qt/qttest-${QTMIN}:5 )
"
RDEPEND="${COMMON_DEPEND}
	x11-base/xorg-server
	!systemd? ( gui-libs/display-manager-init )
"
BDEPEND="
	dev-python/docutils
	>=dev-qt/linguist-tools-${QTMIN}:5
	kde-frameworks/extra-cmake-modules
	virtual/pkgconfig
"

PATCHES=(
	# Downstream patches
	"${FILESDIR}/${P}-respect-user-flags.patch"
	"${FILESDIR}/${PN}-0.18.1-Xsession.patch" # bug 611210
	"${FILESDIR}/${P}-sddm.pam-use-substack.patch" # bug 728550
	"${FILESDIR}/${P}-disable-etc-debian-check.patch"
	"${FILESDIR}/${P}-no-default-pam_systemd-module.patch" # bug 669980
	"${FILESDIR}/${P}-fix-use-development-sessions.patch" # git master
)

pkg_setup() {
	local CONFIG_CHECK="~DRM"
	use kernel_linux && linux-info_pkg_setup
}

src_prepare() {
	cmake_src_prepare

	if ! use test; then
		sed -e "/^find_package/s/ Test//" -i CMakeLists.txt || die
		cmake_comment_add_subdirectory test
	fi
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_MAN_PAGES=ON
		-DDBUS_CONFIG_FILENAME="org.freedesktop.sddm.conf"
		-DRUNTIME_DIR=/run/sddm
		-DSYSTEMD_TMPFILES_DIR="/usr/lib/tmpfiles.d"
		-DNO_SYSTEMD=$(usex !systemd)
		-DUSE_ELOGIND=$(usex elogind)
	)
	cmake_src_configure
}

src_install() {
	cmake_src_install

	# since 0.18.0 sddm no longer installs a config file
	# install one ourselves in gentoo's default location
	insinto /etc/sddm.conf.d/
	newins "${FILESDIR}"/"${PN}".conf 01redcore.conf

	# override gentoo's default location with the
	# classical location which is /etc/sddm.conf
	insinto etc
	doins "${FILESDIR}"/"${PN}".conf
}

pkg_postinst() {
	tmpfiles_process "${PN}".conf
	chown -R "${PN}":"${PN}" /var/lib/"${PN}"

	if use systemd; then
		systemd_reenable sddm.service
	fi
}
