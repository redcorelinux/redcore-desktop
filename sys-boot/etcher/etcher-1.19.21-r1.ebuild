# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

BINTRON_NAME="balena-etcher"
BINTRON_HOME="/opt/balenaEtcher/"

CHROMIUM_LANGS="
	af am ar bg bn ca cs da de el en-GB en-US es-419 es et fa fi fil fr gu he hi hr hu id it ja kn ko lt
	lv ml mr ms nb nl pl pt-BR pt-PT ro ru sk sl sr sv sw ta te th tr uk ur vi zh-CN zh-TW
"

inherit bintron-r1 unpacker

DESCRIPTION="Flash OS images to SD cards & USB drives, safely and easily."
HOMEPAGE="https://etcher.balena.io"
SRC_URI="https://github.com/balena-io/etcher/releases/download/v${PV}/balena-etcher_${PV}_amd64.deb"
S="${WORKDIR}/usr/lib/balena-etcher"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="-* ~amd64"
IUSE="+suid"

RESTRICT="mirror strip test"

RDEPEND="
	virtual/libudev
"

QA_PREBUILT="/opt/balenaEtcher/*"

src_prepare() {
	bintron-r1_src_prepare

	# Weird symlink
	rm balenaEtcher || die
}

src_install() {
	bintron-r1_src_install

	for i in balena-etcher chrome_crashpad_handler chrome-sandbox libEGL.so libGLESv2.so libffmpeg.so libvk_swiftshader.so libvulkan.so.1 ; do
		fperms 0755 "${BINTRON_HOME}"/$i || die
	done

	for i in etcher-util sudo-askpass.osascript-en.js sudo-askpass.osascript-zh.js ; do
		fperms 0755 "${BINTRON_HOME}"/resources/$i || die
	done

	use suid && fperms 4711 "${BINTRON_HOME}"/chrome-sandbox
}
