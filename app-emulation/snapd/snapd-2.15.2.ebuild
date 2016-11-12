# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit golang-vcs-snapshot
inherit systemd

EGO_PN=github.com/snapcore/snapd
EGO_SRC=github.com/snapcore/snapd/...
EGIT_COMMIT="181f66ac30bc3a2bfb8e83c809019c037d34d1f3"

DESCRIPTION="Service and tools for management of snap packages"
HOMEPAGE="http://snapcraft.io/"
SRC_URI="https://github.com/snapcore/${PN}/archive/${PV}.tar.gz -> ${PF}.tar.gz"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64"
RESTRICT="mirror"
RDEPEND="sys-apps/snap-confine
	sys-fs/squashfs-tools:*"
DEPEND="${RDEPEND}
	dev-vcs/git
	dev-vcs/bzr"
src_compile() {
	cp -sR "$(go env GOROOT)" "${T}/goroot" || die
	rm -rf "${T}/goroot/src/${EGO_SRC}" || die
	rm -rf "${T}/goroot/pkg/$(go env GOOS)_$(go env GOARCH)/${EGO_SRC}" || die
	export GOROOT="${T}/goroot"
	export GOPATH="${WORKDIR}/${P}"
	cd src/${EGO_PN} && ./get-deps.sh
	go install -v "${EGO_PN}/cmd/snapd" || die
	go install -v "${EGO_PN}/cmd/snap" || die
}

src_install() {
	export GOPATH="${WORKDIR}/${P}"
	exeinto /usr/bin
	dobin "$GOPATH/bin/snap"
	exeinto /usr/lib/snapd/
	doexe "$GOPATH/bin/snapd"
	cd "src/${EGO_PN}" || die
	systemd_dounit debian/snapd.{service,socket}
	systemd_dounit debian/snapd.refresh.{service,timer}
	sed -i -e 's/RandomizedDelaySec=/#RandomizedDelaySec=/' debian/snapd.refresh.timer
	systemd_dounit debian/snapd.frameworks.target
	systemd_dounit debian/snapd.frameworks-pre.target
	dodir /etc/profile.d/
	echo 'PATH=$PATH:/snap/bin' > ${D}/etc/profile.d/snapd.sh
}

pkg_postinst() {
	systemctl enable snapd.socket
	systemctl enable snapd.refresh.timer
}

pkg_postrm() {
	systemctl disable snapd.service
	systemctl stop snapd.service
	systemctl disable snapd.socket
	systemctl disable snapd.refresh.timer
}
