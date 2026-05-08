# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="OpenPGP keys used for Redcore Linux Project releases (iso, packages)"
HOMEPAGE="https://redcorelinux.org"
SRC_URI=""

LICENSE="public-domain"
SLOT="0"
KEYWORDS="amd64 arm64"
IUSE=""
RESTRICT=""

S=${FILESDIR}

src_install() {
	insinto /usr/share/openpgp-keys
	newins "redcore-release.asc" redcore-release.asc
}
