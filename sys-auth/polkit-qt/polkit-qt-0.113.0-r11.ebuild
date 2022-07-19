# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

MY_P="${P/qt/qt-1}"

DESCRIPTION="PolicyKit Qt API wrapper library (meta package)"
HOMEPAGE="http://www.kde.org/"
SRC_URI=""

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="amd64"
IUSE="+qt5"

RDEPEND="
	qt5? ( ~sys-auth/polkit-qt5-${PV} )
"
DEPEND=""
