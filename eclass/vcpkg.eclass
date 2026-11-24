# Copyright 2026 Redcore Linux Project
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: vcpkg.eclass
# @MAINTAINER:
# Redcore Linux Project <contact@redcorelinux.org>
# @AUTHOR:
# Redcore Linux Project <contact@redcorelinux.org>
# @SUPPORTED_EAPIS: 8
# @BLURB: Fetches a pinned vcpkg release tarball and wires vcpkg.cmake into CMake
# @DESCRIPTION:
# Provides Portage integration for CMake projects using vcpkg manifests.
# Fetches a tagged microsoft/vcpkg release archive (or commit SHA) via SRC_URI,
# binds it to the system dev-build/vcpkg-tool binary, and injects vcpkg.cmake
# via CMAKE_PROJECT_INCLUDE_BEFORE alongside Gentoo's generated toolchain.

case ${EAPI} in
	8) ;;
	*) die "${ECLASS}: EAPI=${EAPI:-0} is not supported" ;;
esac

if [[ -z ${_VCPKG_ECLASS} ]]; then
_VCPKG_ECLASS=1

inherit cmake multiprocessing

# @ECLASS_VARIABLE: VCPKG_VERSION
# @REQUIRED
# @DESCRIPTION:
# Release tag (e.g. "2026.10.16") or 40-char commit SHA of
# https://github.com/microsoft/vcpkg to fetch as the vcpkg registry tree.
# Automatically appended to SRC_URI.
[[ -n ${VCPKG_VERSION} ]] || die "${ECLASS}: VCPKG_VERSION must be set before inheriting ${ECLASS}"

# @ECLASS_VARIABLE: VCPKG_TRIPLET
# @DESCRIPTION:
# Target vcpkg triplet. Auto-detected from CHOST if unset.
if [[ -z ${VCPKG_TRIPLET} ]]; then
	case ${CHOST} in
		x86_64-*-linux-gnu)  VCPKG_TRIPLET="x64-linux" ;;
		aarch64-*-linux-gnu) VCPKG_TRIPLET="arm64-linux" ;;
		i?86-*-linux-gnu)    VCPKG_TRIPLET="x86-linux" ;;
		*)                   VCPKG_TRIPLET="x64-linux" ;;
	esac
fi

# @ECLASS_VARIABLE: VCPKG_OVERLAY_PORTS
# @DEFAULT_UNSET
# @DESCRIPTION:
# Optional path or semicolon-separated paths to custom vcpkg overlay ports.

# @ECLASS_VARIABLE: VCPKG_OVERLAY_TRIPLETS
# @DEFAULT_UNSET
# @DESCRIPTION:
# Optional path or semicolon-separated paths to custom vcpkg overlay triplets.

# @ECLASS_VARIABLE: VCPKG_FEATURES
# @DEFAULT_UNSET
# @DESCRIPTION:
# Semicolon-separated list of vcpkg manifest features to enable.

# @ECLASS_VARIABLE: VCPKG_SHARED_CACHE
# @DESCRIPTION:
# When set to "yes", persists downloaded port archives and binary caches under
# /var/cache/vcpkg across emerges instead of isolating them inside ${T}.
: "${VCPKG_SHARED_CACHE:=no}"

if [[ ${VCPKG_VERSION} =~ ^[0-9a-f]{40}$ ]]; then
	SRC_URI+=" https://github.com/microsoft/vcpkg/archive/${VCPKG_VERSION}.tar.gz -> vcpkg-${VCPKG_VERSION}.tar.gz"
else
	SRC_URI+=" https://github.com/microsoft/vcpkg/archive/refs/tags/${VCPKG_VERSION}.tar.gz -> vcpkg-${VCPKG_VERSION}.tar.gz"
fi

# vcpkg manifest mode fetches upstream port source archives during configure
PROPERTIES+=" live"
RESTRICT+=" network-sandbox"

BDEPEND="dev-build/vcpkg-tool"

# @FUNCTION: _vcpkg_get_root
# @INTERNAL
# @DESCRIPTION:
# Echoes the path to the unpacked vcpkg registry directory in ${WORKDIR}.
_vcpkg_get_root() {
	echo "${WORKDIR}/vcpkg-${VCPKG_VERSION}"
}

# @FUNCTION: vcpkg_src_unpack
# @DESCRIPTION:
# Unpacks SRC_URI archives and binds the system vcpkg-tool binary into the
# unpacked registry tree without invoking bootstrap-vcpkg.sh.
vcpkg_src_unpack() {
	default

	local vcpkg_root="$(_vcpkg_get_root)"
	[[ -d "${vcpkg_root}" ]] || die "${ECLASS}: expected unpacked registry at ${vcpkg_root}"

	touch "${vcpkg_root}/.vcpkg-root" || die
	ln -snf "${VCPKG_SYSTEM_BINARY:-${BROOT}/usr/bin/vcpkg}" "${vcpkg_root}/vcpkg" || die
}

# @FUNCTION: vcpkg_src_configure
# @DESCRIPTION:
# Configures CMake with CMAKE_PROJECT_INCLUDE_BEFORE pointing to vcpkg.cmake,
# sets sandbox-safe cache paths, and passes manifest mode options.
vcpkg_src_configure() {
	local jobs="$(get_makeopts_jobs)"
	export VCPKG_MAX_CONCURRENCY="${jobs}"
	export CMAKE_BUILD_PARALLEL_LEVEL="${jobs}"

	local vcpkg_root="$(_vcpkg_get_root)"
	local downloads_dir="${T}/vcpkg-downloads"
	local bincache_dir="${T}/vcpkg-bincache"

	if [[ ${VCPKG_SHARED_CACHE} == yes ]]; then
		downloads_dir="${EROOT}/var/cache/vcpkg/downloads"
		bincache_dir="${EROOT}/var/cache/vcpkg/bincache"
		addwrite "${EROOT}/var/cache/vcpkg"
	fi

	mkdir -p "${downloads_dir}" "${bincache_dir}" || die

	export VCPKG_ROOT="${vcpkg_root}"
	export VCPKG_FORCE_SYSTEM_BINARIES=1
	export VCPKG_DISABLE_METRICS=1
	export VCPKG_DOWNLOADS="${downloads_dir}"
	export VCPKG_DEFAULT_BINARY_CACHE="${bincache_dir}"

	local mycmakeargs=(
		-DCMAKE_PROJECT_INCLUDE_BEFORE="${vcpkg_root}/scripts/buildsystems/vcpkg.cmake"
		-DVCPKG_TARGET_TRIPLET="${VCPKG_TRIPLET}"
		-DVCPKG_HOST_TRIPLET="${VCPKG_TRIPLET}"
		-DVCPKG_INSTALLED_DIR="${BUILD_DIR}/vcpkg_installed"
		${VCPKG_OVERLAY_PORTS:+-DVCPKG_OVERLAY_PORTS="${VCPKG_OVERLAY_PORTS}"}
		${VCPKG_OVERLAY_TRIPLETS:+-DVCPKG_OVERLAY_TRIPLETS="${VCPKG_OVERLAY_TRIPLETS}"}
		${VCPKG_FEATURES:+-DVCPKG_MANIFEST_FEATURES="${VCPKG_FEATURES}"}
		"${mycmakeargs[@]}"
	)

	cmake_src_configure "$@"
}

fi

EXPORT_FUNCTIONS src_unpack src_configure
