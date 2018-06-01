# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 python3_{5,6} pypy )

LLVM_MAX_SLOT=4

inherit multiprocessing multilib-build git-r3 python-any-r1 llvm toolchain-funcs

SLOT="git"
MY_P="rust-git"
EGIT_REPO_URI="https://github.com/rust-lang/rust.git"

EGIT_CHECKOUT_DIR="${MY_P}-src"

CHOST_amd64=x86_64-unknown-linux-gnu
CHOST_x86=i686-unknown-linux-gnu
CHOST_arm64=aarch64-unknown-linux-gnu

DESCRIPTION="Systems programming language from Mozilla"
HOMEPAGE="http://www.rust-lang.org/"

LICENSE="|| ( MIT Apache-2.0 ) BSD-1 BSD-2 BSD-4 UoI-NCSA"
KEYWORDS=""

ALL_LLVM_TARGETS=( AArch64 AMDGPU ARM BPF Hexagon Lanai Mips MSP430
	NVPTX PowerPC Sparc SystemZ X86 XCore )
ALL_LLVM_TARGETS=( "${ALL_LLVM_TARGETS[@]/#/llvm_targets_}" )
LLVM_TARGET_USEDEPS=${ALL_LLVM_TARGETS[@]/%/?}

IUSE="clang debug doc source +system-llvm sanitize extended ${ALL_LLVM_TARGETS[*]}"

CDEPEND="clang? ( sys-libs/libcxx )
	>=app-eselect/eselect-rust-0.3_pre20150425
	!dev-lang/rust:0
	system-llvm? ( >=sys-devel/llvm-3.8.1-r2:=
			<sys-devel/llvm-5.0.0:= )
"
DEPEND="${CDEPEND}
	${PYTHON_DEPS}
	net-misc/curl
	clang? (
		<sys-devel/clang-6_pre:=
		|| (
			sys-devel/clang:4
			>=sys-devel/clang-3.5:0
		)
	)
	!clang? ( >=sys-devel/gcc-4.7 )
	dev-util/cmake
	sanitize? ( >=sys-kernel/linux-headers-3.2 )
"
RDEPEND="${CDEPEND}
"
PDEPEND="dev-util/cargo"

REQUIRED_USE="source? ( extended )
|| ( ${ALL_LLVM_TARGETS[*]} )"

S="${WORKDIR}/${MY_P}-src"

toml_usex() {
	usex "$1" true false
}

toml_tools_list() {
	if use extended; then
		echo "tools=[$(usex source "\"src\", " "")\"rls\", \"analysis\"]"
	fi
}

pkg_setup() {
	python-any-r1_pkg_setup
	if use system-llvm; then
		EGIT_SUBMODULES=( "*" "-src/llvm" )
		llvm_pkg_setup
	fi
}

src_prepare() {
	local rust_stage0_root="${WORKDIR}"/rust-stage0

	default
}

src_unpack() {
	git-r3_src_unpack
}

src_configure() {
	# We need to ask llvm-config to link to dynamic libraries
	# because LLVM ebuild does not provide an option
	# to compile static libraries
	if use system-llvm; then
		export LLVM_LINK_SHARED=1
		local llvm_config="$(get_llvm_prefix)/bin/${CBUILD}-llvm-config"
	fi

	python_setup

	local rust_target="" rust_targets="" rust_target_name arch_cflags

	# Collect rust target names to compile standard libs for all ABIs.
	for v in $(multilib_get_enabled_abi_pairs); do
		rust_target_name="CHOST_${v##*.}"
		rust_targets="${rust_targets},\"${!rust_target_name}\""
	done
	rust_targets="${rust_targets#,}"

	local rust_target_name="CHOST_${ARCH}"
	local rust_target="${!rust_target_name}"

	export CFG_DISABLE_LDCONFIG="notempty"

	cat <<- EOF > "${S}"/config.toml
		[llvm]
		optimize = $(toml_usex !debug)
		release-debuginfo = $(toml_usex debug)
		assertions = $(toml_usex debug)
		targets = "${LLVM_TARGETS// /;}"
		[build]
		build = "${rust_target}"
		host = ["${rust_target}"]
		target = [${rust_targets}]
		docs = $(toml_usex doc)
		submodules = false
		python = "${EPYTHON}"
		locked-deps = true
		vendor = false
		verbose = 2
		sanitizers = $(toml_usex sanitize)
		extended = $(toml_usex extended)
		$(toml_tools_list)
		[install]
		prefix = "${EPREFIX}/usr"
		libdir = "$(get_libdir)/${P}"
		docdir = "share/doc/${P}"
		mandir = "share/${P}/man"
		[rust]
		optimize = $(toml_usex !debug)
		debuginfo = $(toml_usex debug)
		debug-assertions = $(toml_usex debug)
		use-jemalloc = true
		default-linker = "$(tc-getCC)"
		rpath = false
		ignore-git = false
	EOF

	for v in $(multilib_get_enabled_abi_pairs); do
		rust_target=$(get_abi_CHOST ${v##*.})
		arch_cflags="$(get_abi_CFLAGS ${v##*.})"

		cat <<- EOF >> "${S}"/config.env
			CFLAGS_${rust_target}=${arch_cflags}
		EOF

		local c_compiler="$(tc-getBUILD_CC)"
		local cxx_compiler="$(tc-getBUILD_CXX)"
		if use clang ; then
			c_compiler="${CBUILD}-clang"
			cxx_compiler="${CBUILD}-clang++"
		fi

		cat <<- EOF >> "${S}"/config.toml
			[target.${rust_target}]
			cc = "${c_compiler}"
			cxx = "${cxx_compiler}"
			linker = "$(tc-getCC)"
			ar = "$(tc-getAR)"
		EOF

		if use system-llvm; then
			cat <<- EOF >> "${S}"/config.toml
				llvm-config = "${llvm_config}"
			EOF
		fi
	done

}

src_compile() {
	env $(cat "${S}"/config.env)\
		${EPYTHON} x.py build --verbose --config="${S}"/config.toml $(echo ${MAKEOPTS} | egrep -o '(\-j|\-\-jobs)(=?|[[:space:]]*)[[:digit:]]+') || die
}

src_install() {
	local rust_target_abi_libdir

	env DESTDIR="${D}" ${EPYTHON} x.py install  --verbose --config="${S}"/config.toml $(echo ${MAKEOPTS} | egrep -o '(\-j|\-\-jobs)(=?|[[:space:]]*)[[:digit:]]+') || die

	mv "${D}/usr/bin/rustc" "${D}/usr/bin/rustc-${PV}" || die
	mv "${D}/usr/bin/rustdoc" "${D}/usr/bin/rustdoc-${PV}" || die
	mv "${D}/usr/bin/rust-gdb" "${D}/usr/bin/rust-gdb-${PV}" || die
	mv "${D}/usr/bin/rust-lldb" "${D}/usr/bin/rust-lldb-${PV}" || die
	if use extended; then
		mv "${D}/usr/bin/rls" "${D}/usr/bin/rls-${PV}" || die
	fi

	# Copy shared library versions of standard libraries for all targets
	# into the system's abi-dependent lib directories because the rust
	# installer only does so for the native ABI.
	for v in $(multilib_get_enabled_abi_pairs); do
		if [ ${v##*.} = ${DEFAULT_ABI} ]; then
			continue
		fi
		abi_libdir=$(get_abi_LIBDIR ${v##*.})
		rust_target=$(get_abi_CHOST ${v##*.})
		mkdir -p ${D}/usr/${abi_libdir}
		cp ${D}/usr/$(get_libdir)/${P}/rustlib/${rust_target}/lib/*.so \
		   ${D}/usr/${abi_libdir} || die
	done

	dodoc COPYRIGHT LICENSE-APACHE LICENSE-MIT

	cat <<-EOF > "${T}"/50${P}
	LDPATH="/usr/$(get_libdir)/${P}"
	MANPATH="/usr/share/${P}/man"
	EOF
	if use source; then
		cat <<-EOF >> "${T}"/50${P}
		RUST_SRC_PATH="/usr/$(get_libdir)/${P}/rustlib/src/rust/src/"
		EOF
	fi
	doenvd "${T}"/50${P}

	cat <<-EOF > "${T}/provider-${P}"
	/usr/bin/rustdoc
	/usr/bin/rust-gdb
	/usr/bin/rust-lldb
	EOF
	if use extended; then
	    cat <<-EOF >> "${T}/provider-${P}"
		/usr/bin/rls
		EOF
	fi
	dodir /etc/env.d/rust
	insinto /etc/env.d/rust
	doins "${T}/provider-${P}"

	rm -rf "${D}/usr/$(get_libdir)/rustlib/src/"
}

pkg_postinst() {
	eselect rust update --if-unset

	elog "Rust installs a helper script for calling GDB now,"
	elog "for your convenience it is installed under /usr/bin/rust-gdb-${PV}."

	if has_version app-editors/emacs || has_version app-editors/emacs-vcs; then
		elog "install app-emacs/rust-mode to get emacs support for rust."
	fi

	if has_version app-editors/gvim || has_version app-editors/vim; then
		elog "install app-vim/rust-mode to get vim support for rust."
	fi

	if has_version 'app-shells/zsh'; then
		elog "install app-shells/rust-zshcomp to get zsh completion for rust."
	fi
}

pkg_postrm() {
	eselect rust unset --if-invalid
}
