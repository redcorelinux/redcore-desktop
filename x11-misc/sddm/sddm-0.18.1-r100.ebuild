# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PLOCALES="ar bn ca cs da de es et fi fr hi_IN hu is it ja kk ko lt lv nb nl nn pl pt_BR pt_PT ro ru sk sr sr@ijekavian sr@ijekavianlatin sr@latin sv tr uk zh_CN zh_TW"
inherit cmake plocale systemd user

DESCRIPTION="Simple Desktop Display Manager"
HOMEPAGE="https://github.com/sddm/sddm"
SRC_URI="https://github.com/${PN}/${PN}/releases/download/v${PV}/${P}.tar.xz"

LICENSE="GPL-2+ MIT CC-BY-3.0 CC-BY-SA-3.0 public-domain"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~ppc64 ~x86"
IUSE="+branding consolekit elogind +pam systemd test"
RESTRICT="!test? ( test )"

REQUIRED_USE="?? ( elogind systemd )"

BDEPEND="
	dev-python/docutils
	>=dev-qt/linguist-tools-5.9.4:5
	kde-frameworks/extra-cmake-modules:5
	virtual/pkgconfig
"
RDEPEND="
	>=dev-qt/qtcore-5.9.4:5
	>=dev-qt/qtdbus-5.9.4:5
	>=dev-qt/qtdeclarative-5.9.4:5
	>=dev-qt/qtgui-5.9.4:5
	>=dev-qt/qtnetwork-5.9.4:5
	>=x11-base/xorg-server-1.15.1
	x11-libs/libxcb[xkb]
	branding? ( x11-themes/redcore-theme-sddm )
	consolekit? ( >=sys-auth/consolekit-0.9.4 )
	elogind? ( sys-auth/elogind )
	pam? ( sys-libs/pam )
	systemd? ( sys-apps/systemd:= )
	!systemd? ( sys-power/upower )
"
DEPEND="${RDEPEND}
	test? ( >=dev-qt/qttest-5.9.4:5 )
"

PATCHES=(
	"${FILESDIR}/${PN}-0.12.0-respect-user-flags.patch"
	"${FILESDIR}/${PN}-0.18.0-Xsession.patch" # bug 611210
	"${FILESDIR}/${PN}-0.18.0-sddmconfdir.patch"
	# fix for groups: https://github.com/sddm/sddm/issues/1159
	"${FILESDIR}/${P}-revert-honor-PAM-supplemental-groups.patch"
	"${FILESDIR}/${P}-honor-PAM-supplemental-groups-v2.patch"
	# fix for ReuseSession=true
	"${FILESDIR}/${P}-only-reuse-online-sessions.patch"
	# TODO: fix properly
	"${FILESDIR}/${PN}-0.16.0-ck2-revert.patch" # bug 633920
	"${FILESDIR}/pam-1.4-substack.patch"
	# upstream git develop branch:
	"${FILESDIR}/${P}-qt-5.15.2.patch"
)

src_prepare() {
	cmake_src_prepare

	disable_locale() {
		sed -e "/${1}\.ts/d" -i data/translations/CMakeLists.txt || die
	}
	plocale_find_changes "data/translations" "" ".ts"
	plocale_for_each_disabled_locale disable_locale

	if ! use test; then
		sed -e "/^find_package/s/ Test//" -i CMakeLists.txt || die
		cmake_comment_add_subdirectory test
	fi
}

src_configure() {
	local mycmakeargs=(
		-DENABLE_PAM=$(usex pam)
		-DNO_SYSTEMD=$(usex '!systemd')
		-DUSE_ELOGIND=$(usex 'elogind')
		-DBUILD_MAN_PAGES=ON
		-DDBUS_CONFIG_FILENAME="org.freedesktop.sddm.conf"
	)
	cmake_src_configure
}

src_install() {
	cmake_src_install

	# since 0.18.0 sddm no longer installs a config file
	# install one ourselves in gentoo's default location
	local confd="usr/share/sddm/sddm.conf.d"
	dodir ${confd}
	insinto ${confd}
	newins ${FILESDIR}/${PN}.conf 00default.conf

	# override gentoo's default location with the
	# classical location which is /etc/sddm.conf
	insinto etc
	doins ${FILESDIR}/${PN}.conf
}

pkg_postinst() {
	enewgroup ${PN}
	enewuser ${PN} -1 -1 /var/lib/${PN} ${PN},video

	systemd_reenable sddm.service
}