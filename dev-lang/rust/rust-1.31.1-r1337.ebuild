# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 python3_{5,6} pypy )

inherit check-reqs eapi7-ver estack flag-o-matic llvm multiprocessing multilib-build python-any-r1 rust-toolchain toolchain-funcs

if [[ ${PV} = *beta* ]]; then
	betaver=${PV//*beta}
	BETA_SNAPSHOT="${betaver:0:4}-${betaver:4:2}-${betaver:6:2}"
	MY_P="rustc-beta"
	SLOT="beta/${PV}"
	SRC="${BETA_SNAPSHOT}/rustc-beta-src.tar.xz"
else
	ABI_VER="$(ver_cut 1-2)"
	SLOT="stable/${ABI_VER}"
	MY_P="rustc-${PV}"
	SRC="${MY_P}-src.tar.xz"
	KEYWORDS="~amd64"
fi

RUST_STAGE0_VERSION="1.$(($(ver_cut 2) - 1)).1"

DESCRIPTION="Systems programming language from Mozilla"
HOMEPAGE="https://www.rust-lang.org/"

SRC_URI="https://static.rust-lang.org/dist/${SRC} -> rustc-${PV}-src.tar.xz
		$(rust_arch_uri x86_64-unknown-linux-gnu rust-${RUST_STAGE0_VERSION})"

ALL_LLVM_TARGETS=( AArch64 AMDGPU ARM BPF Hexagon Lanai Mips MSP430
	NVPTX PowerPC Sparc SystemZ X86 XCore )
ALL_LLVM_TARGETS=( "${ALL_LLVM_TARGETS[@]/#/llvm_targets_}" )
LLVM_TARGET_USEDEPS=${ALL_LLVM_TARGETS[@]/%/?}

LICENSE="|| ( MIT Apache-2.0 ) BSD-1 BSD-2 BSD-4 UoI-NCSA"

IUSE="clippy cpu_flags_x86_sse2 debug doc +jemalloc libressl rls rustfmt system-llvm wasm ${ALL_LLVM_TARGETS[*]}"

COMMON_DEPEND="
		jemalloc? ( dev-libs/jemalloc )
		sys-libs/zlib
		!libressl? ( dev-libs/openssl:0= )
		libressl? ( dev-libs/libressl:0= )
		net-libs/libssh2
		net-libs/http-parser:=
		net-misc/curl[ssl]
		system-llvm? ( >=sys-devel/llvm-6:= )"
DEPEND="${COMMON_DEPEND}
	${PYTHON_DEPS}
	|| (
		>=sys-devel/gcc-4.7
		>=sys-devel/clang-3.5
	)
	dev-util/cmake"
RDEPEND="${COMMON_DEPEND}
	!dev-util/cargo
	rustfmt? ( !dev-util/rustfmt )"
REQUIRED_USE="|| ( ${ALL_LLVM_TARGETS[*]} )
				x86? ( cpu_flags_x86_sse2 )"

S="${WORKDIR}/${MY_P}-src"

PATCHES=( "${FILESDIR}"/1.30.1-clippy-sysroot.patch )

toml_usex() {
	usex "$1" true false
}

pre_build_checks() {
	CHECKREQS_DISK_BUILD="7G"
	CHECKREQS_MEMORY="4G"
	eshopts_push -s extglob
	if is-flagq '-g?(gdb)?([1-9])'; then
		CHECKREQS_DISK_BUILD="10G"
		CHECKREQS_MEMORY="16G"
	fi
	eshopts_pop
	check-reqs_pkg_setup
}

pkg_pretend() {
	pre_build_checks
}

pkg_setup() {
	pre_build_checks
	python-any-r1_pkg_setup
	if use system-llvm; then
		llvm_pkg_setup
	fi
}

src_prepare() {
	local rust_stage0_root="${WORKDIR}"/rust-stage0

	local rust_stage0="rust-${RUST_STAGE0_VERSION}-$(rust_abi)"

	"${WORKDIR}/${rust_stage0}"/install.sh --disable-ldconfig --destdir="${rust_stage0_root}" --prefix=/ || die

	default
}

src_configure() {
	local rust_target="" rust_targets="" arch_cflags

	# Collect rust target names to compile standard libs for all ABIs.
	for v in $(multilib_get_enabled_abi_pairs); do
		rust_targets="${rust_targets},\"$(rust_abi $(get_abi_CHOST ${v##*.}))\""
	done
	if use wasm; then
		rust_targets="${rust_targets},\"wasm32-unknown-unknown\""
	fi
	rust_targets="${rust_targets#,}"

	local extended="true" tools="\"cargo\","
	if use clippy; then
		tools="\"clippy\",$tools"
	fi
	if use rls; then
		tools="\"rls\",\"analysis\",\"src\",$tools"
	fi
	if use rustfmt; then
		tools="\"rustfmt\",$tools"
	fi

	local rust_stage0_root="${WORKDIR}"/rust-stage0

	rust_target="$(rust_abi)"

	cat <<- EOF > "${S}"/config.toml
		[llvm]
		optimize = $(toml_usex !debug)
		release-debuginfo = $(toml_usex debug)
		assertions = $(toml_usex debug)
		targets = "${LLVM_TARGETS// /;}"
		link-shared = $(toml_usex system-llvm)
		[build]
		build = "${rust_target}"
		host = ["${rust_target}"]
		target = [${rust_targets}]
		cargo = "${rust_stage0_root}/bin/cargo"
		rustc = "${rust_stage0_root}/bin/rustc"
		docs = $(toml_usex doc)
		submodules = false
		python = "${EPYTHON}"
		locked-deps = true
		vendor = true
		extended = ${extended}
		tools = [${tools}]
		[install]
		prefix = "${EPREFIX}/usr"
		libdir = "$(get_libdir)/${P}"
		docdir = "share/doc/${P}"
		mandir = "share/${P}/man"
		[rust]
		optimize = $(toml_usex !debug)
		debuginfo = $(toml_usex debug)
		debug-assertions = $(toml_usex debug)
		use-jemalloc = $(toml_usex jemalloc)
		default-linker = "$(tc-getCC)"
		channel = "stable"
		rpath = false
		lld = $(toml_usex wasm)
	EOF

	for v in $(multilib_get_enabled_abi_pairs); do
		rust_target=$(rust_abi $(get_abi_CHOST ${v##*.}))
		arch_cflags="$(get_abi_CFLAGS ${v##*.})"

		cat <<- EOF >> "${S}"/config.env
			CFLAGS_${rust_target}=${arch_cflags}
		EOF

		cat <<- EOF >> "${S}"/config.toml
			[target.${rust_target}]
			cc = "$(tc-getBUILD_CC)"
			cxx = "$(tc-getBUILD_CXX)"
			linker = "$(tc-getCC)"
			ar = "$(tc-getAR)"
		EOF
		if use system-llvm; then
			cat <<- EOF >> "${S}"/config.toml
				llvm-config = "$(get_llvm_prefix)/bin/llvm-config"
			EOF
		fi
	done

	if use wasm; then
		cat <<- EOF >> "${S}"/config.toml
			[target.wasm32-unknown-unknown]
			linker = "rust-lld"
		EOF
	fi
}

src_compile() {
	env $(cat "${S}"/config.env)\
		"${EPYTHON}" ./x.py build --config="${S}"/config.toml -j$(makeopts_jobs) \
		--exclude src/tools/miri || die # https://github.com/rust-lang/rust/issues/52305
}

src_install() {
	local rust_target abi_libdir

	env DESTDIR="${D}" "${EPYTHON}" ./x.py install || die

	# Copy shared library versions of standard libraries for all targets
	# into the system's abi-dependent lib directories because the rust
	# installer only does so for the native ABI.
	for v in $(multilib_get_enabled_abi_pairs); do
		if [ ${v##*.} = ${DEFAULT_ABI} ]; then
			continue
		fi
		abi_libdir=$(get_abi_LIBDIR ${v##*.})
		rust_target=$(rust_abi $(get_abi_CHOST ${v##*.}))
		mkdir -p "${D}/usr/${abi_libdir}"
		cp "${D}/usr/$(get_libdir)/${P}/rustlib/${rust_target}/lib"/*.so \
		   "${D}/usr/${abi_libdir}" || die
	done

	dodoc COPYRIGHT

	# FIXME:
	# Really not sure if that env is needed, specailly LDPATH
	cat <<-EOF > "${T}"/50${P}
		LDPATH="/usr/$(get_libdir)/${P}"
		MANPATH="/usr/share/${P}/man"
	EOF
	doenvd "${T}"/50${P}
}
