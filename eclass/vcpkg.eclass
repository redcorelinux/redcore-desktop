# Copyright 2026 Redcore Linux Project
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: vcpkg.eclass
# @MAINTAINER:
# Redcore Linux Project <contact@redcorelinux.org>
# @AUTHOR:
# Redcore Linux Project <contact@redcorelinux.org>
# @SUPPORTED_EAPIS: 8
# @BLURB: Common functions and variables for vcpkg manifest-mode CMake builds
# @DESCRIPTION:
# Provides Portage integration for CMake projects using vcpkg manifests,
# modeled on cargo.eclass conventions. Fetches a pinned microsoft/vcpkg
# snapshot via SRC_URI, isolates vcpkg configuration and cache directories
# inside ${EVCPKG_HOME} (or a configurable shared cache), and wires
# vcpkg.cmake into CMake.

case ${EAPI} in
	8) ;;
	*) die "${ECLASS}: EAPI=${EAPI:-0} is not supported" ;;
esac

if [[ -z ${_VCPKG_ECLASS} ]]; then
_VCPKG_ECLASS=1

inherit cmake multiprocessing

# @ECLASS_VARIABLE: VCPKG_VERSION
# @REQUIRED
# @PRE_INHERIT
# @DESCRIPTION:
# Release tag (e.g. "2026.10.16") or 40-char commit SHA of
# https://github.com/microsoft/vcpkg to fetch as the vcpkg registry tree.
# Automatically appended to SRC_URI.
[[ -n ${VCPKG_VERSION} ]] || die "${ECLASS}: VCPKG_VERSION must be set before inheriting ${ECLASS}"

# @ECLASS_VARIABLE: EVCPKG_HOME
# @INTERNAL
# @DESCRIPTION:
# Location of the isolated vcpkg working home directory inside ${WORKDIR}.
EVCPKG_HOME="${WORKDIR}/vcpkg_home"

# @ECLASS_VARIABLE: EVCPKG_ROOT
# @INTERNAL
# @DESCRIPTION:
# Location of the unpacked vcpkg registry and buildsystem tree.
EVCPKG_ROOT="${WORKDIR}/vcpkg-${VCPKG_VERSION}"

# @ECLASS_VARIABLE: VCPKG_TRIPLET
# @DESCRIPTION:
# Target vcpkg triplet. Auto-detected from CHOST if unset (e.g. "x64-linux").
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
# When set to "yes" (e.g. in make.conf), persists downloaded port archives and
# binary caches under VCPKG_CACHE_DIR across emerges instead of isolating
# them inside ${EVCPKG_HOME}.
: "${VCPKG_SHARED_CACHE:=no}"

# @ECLASS_VARIABLE: VCPKG_CACHE_DIR
# @DESCRIPTION:
# Base directory for persistent vcpkg downloads and binary archives when
# VCPKG_SHARED_CACHE="yes". Defaults to "${EROOT}/var/cache/vcpkg".
: "${VCPKG_CACHE_DIR:=${EROOT}/var/cache/vcpkg}"

if [[ ${VCPKG_VERSION} =~ ^[0-9a-f]{40}$ ]]; then
	SRC_URI+=" https://github.com/microsoft/vcpkg/archive/${VCPKG_VERSION}.tar.gz -> vcpkg-${VCPKG_VERSION}.tar.gz"
else
	SRC_URI+=" https://github.com/microsoft/vcpkg/archive/refs/tags/${VCPKG_VERSION}.tar.gz -> vcpkg-${VCPKG_VERSION}.tar.gz"
fi

PROPERTIES+=" live"
RESTRICT+=" network-sandbox"
BDEPEND="dev-build/vcpkg-tool"

# @FUNCTION: vcpkg_gen_config
# @DESCRIPTION:
# Initializes the isolated ${EVCPKG_HOME} directory layout, mirroring
# cargo_gen_config in cargo.eclass.
vcpkg_gen_config() {
	mkdir -p "${EVCPKG_HOME}" || die
}

# @FUNCTION: vcpkg_src_unpack
# @DESCRIPTION:
# Unpacks SRC_URI archives, binds the system vcpkg-tool binary into
# ${EVCPKG_ROOT}, and initializes ${EVCPKG_HOME} via vcpkg_gen_config.
vcpkg_src_unpack() {
	default

	[[ -d "${EVCPKG_ROOT}" ]] || die "${ECLASS}: expected unpacked registry at ${EVCPKG_ROOT}"

	touch "${EVCPKG_ROOT}/.vcpkg-root" || die
	ln -snf "${VCPKG_SYSTEM_BINARY:-${BROOT}/usr/bin/vcpkg}" "${EVCPKG_ROOT}/vcpkg" || die

	vcpkg_gen_config
}

# @FUNCTION: vcpkg_env
# @USAGE: <command> [<args>...]
# @DESCRIPTION:
# Runs a command with Portage's vcpkg environment variables exported,
# analogous to cargo_env in cargo.eclass.
vcpkg_env() {
	local downloads_dir="${EVCPKG_HOME}/downloads"
	local bincache_dir="${EVCPKG_HOME}/bincache"

	if [[ ${VCPKG_SHARED_CACHE} == yes ]]; then
		downloads_dir="${VCPKG_CACHE_DIR}/downloads"
		bincache_dir="${VCPKG_CACHE_DIR}/bincache"
		addwrite "${VCPKG_CACHE_DIR}"
	fi

	mkdir -p "${downloads_dir}" "${bincache_dir}" || die

	local jobs="$(get_makeopts_jobs)"

	local -x VCPKG_ROOT="${EVCPKG_ROOT}"
	local -x VCPKG_FORCE_SYSTEM_BINARIES=1
	local -x VCPKG_DISABLE_METRICS=1
	local -x VCPKG_DOWNLOADS="${downloads_dir}"
	local -x VCPKG_DEFAULT_BINARY_CACHE="${bincache_dir}"
	local -x VCPKG_MAX_CONCURRENCY="${jobs}"
	local -x CMAKE_BUILD_PARALLEL_LEVEL="${jobs}"

	"${@}"
}

# @FUNCTION: vcpkg_src_configure
# @DESCRIPTION:
# Configures CMake via vcpkg_env, injecting vcpkg.cmake through
# CMAKE_PROJECT_INCLUDE_BEFORE and pointing installed artifacts into
# ${BUILD_DIR}/vcpkg_installed.
vcpkg_src_configure() {
	[[ -d "${EVCPKG_HOME}" ]] || vcpkg_gen_config

	local mycmakeargs=(
		-DCMAKE_PROJECT_INCLUDE_BEFORE="${EVCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake"
		-DVCPKG_TARGET_TRIPLET="${VCPKG_TRIPLET}"
		-DVCPKG_HOST_TRIPLET="${VCPKG_TRIPLET}"
		-DVCPKG_INSTALLED_DIR="${BUILD_DIR}/vcpkg_installed"
		${VCPKG_OVERLAY_PORTS:+-DVCPKG_OVERLAY_PORTS="${VCPKG_OVERLAY_PORTS}"}
		${VCPKG_OVERLAY_TRIPLETS:+-DVCPKG_OVERLAY_TRIPLETS="${VCPKG_OVERLAY_TRIPLETS}"}
		${VCPKG_FEATURES:+-DVCPKG_MANIFEST_FEATURES="${VCPKG_FEATURES}"}
		"${mycmakeargs[@]}"
	)

	vcpkg_env cmake_src_configure "$@"
}

fi

EXPORT_FUNCTIONS src_unpack src_configure
