# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 )

LLVM_MAX_SLOT=4

inherit git-r3 multilib python-any-r1 llvm

SLOT="git"
MY_P="rust-git"
EGIT_REPO_URI="https://github.com/rust-lang/rust.git"
EGIT_CHECKOUT_DIR="${MY_P}-src"

DESCRIPTION="Systems programming language from Mozilla"
HOMEPAGE="http://www.rust-lang.org/"

LICENSE="|| ( MIT Apache-2.0 ) BSD-1 BSD-2 BSD-4 UoI-NCSA"
KEYWORDS=""

IUSE="clang debug doc source +system-llvm sanitize tools"

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
			>=sys-devel/clang-3:0
		)
	)
	!clang? ( >=sys-devel/gcc-4.7 )
	dev-util/cmake
	sanitize? ( >=sys-kernel/linux-headers-3.2 )
"
RDEPEND="${CDEPEND}
"
PDEPEND="dev-util/cargo"

S="${WORKDIR}/${MY_P}-src"

toml_usex() {
	usex "$1" true false
}

pkg_setup() {
	python-any-r1_pkg_setup
	if use system-llvm; then
		EGIT_SUBMODULES=( "*" "-src/llvm" )
		llvm_pkg_setup
	fi
}

src_prepare() {
	default

    use amd64 && BUILD_TRIPLE=x86_64-unknown-linux-gnu
    use x86 && BUILD_TRIPLE=i686-unknown-linux-gnu
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

	local rust_target="${BUILD_TRIPLE}"

	local archiver="$(tc-getAR)"
	local linker="$(tc-getCC)"

	local c_compiler="$(tc-getBUILD_CC)"
	local cxx_compiler="$(tc-getBUILD_CXX)"
	if use clang ; then
		c_compiler="${CBUILD}-clang"
		cxx_compiler="${CBUILD}-clang++"
	fi

	export CFG_DISABLE_LDCONFIG="notempty"

	cat <<- EOF > "${S}"/config.toml
		[llvm]
		optimize = $(toml_usex !debug)
		release-debuginfo = $(toml_usex debug)
		assertions = $(toml_usex debug)
		[build]
		build = "${rust_target}"
		host = ["${rust_target}"]
		target = ["${rust_target}"]
		docs = $(toml_usex doc)
		submodules = false
		python = "${EPYTHON}"
		locked-deps = true
		vendor = false
		verbose = 2
		sanitizers = $(toml_usex sanitize)
		extended = $(toml_usex tools)
		[install]
		prefix = "${EPREFIX}/usr"
		libdir = "$(get_libdir)"
		docdir = "share/doc/${P}"
		mandir = "share/${P}/man"
		[rust]
		optimize = $(toml_usex !debug)
		debuginfo = $(toml_usex debug)
		debug-assertions = $(toml_usex debug)
		use-jemalloc = true
		default-linker = "${linker}"
		default-ar = "${archiver}"
		rpath = true
		[target.${rust_target}]
		cc = "${c_compiler}"
		cxx = "${cxx_compiler}"
	EOF

	if use system-llvm; then
		cat <<- EOF >> "${S}"/config.toml
			llvm-config = "${llvm_config}"
		EOF
	fi

}

src_compile() {
	${EPYTHON} x.py build --verbose --config="${S}"/config.toml ${MAKEOPTS} || die
}

src_install() {
	env DESTDIR="${D}" ${EPYTHON} x.py install  --verbose --config="${S}"/config.toml ${MAKEOPTS} || die

	mv "${D}/usr/bin/rustc" "${D}/usr/bin/rustc-${PV}" || die
	mv "${D}/usr/bin/rustdoc" "${D}/usr/bin/rustdoc-${PV}" || die
	mv "${D}/usr/bin/rust-gdb" "${D}/usr/bin/rust-gdb-${PV}" || die
	mv "${D}/usr/bin/rust-lldb" "${D}/usr/bin/rust-lldb-${PV}" || die
	if use tools; then
		mv "${D}/usr/bin/rls" "${D}/usr/bin/rls-${PV}" || die
		# remove cargo
		rm -f "${D}/usr/bin/cargo" || die
		rm -f "${D}/usr/share/zsh/site-functions/_cargo" || die
		rm -f "${D}/usr/share/rust-9999/man/man1/cargo*" || die
		rm -f "${D}/etc/bash_completion.d/cargo" || die
		rm -f "${D}/usr/lib64/rust-9999/rustlib/manifest-cargo" || die
	fi

	dodoc COPYRIGHT LICENSE-APACHE LICENSE-MIT

	cat <<-EOF > "${T}"/50${P}
	LDPATH="/usr/$(get_libdir)/${P}"
	MANPATH="/usr/share/${P}/man"
	EOF
	if use source; then
		cat <<-EOF >> "${T}"/50${P}
		RUST_SRC_PATH="/usr/share/${P}/src"
		EOF
	fi
	doenvd "${T}"/50${P}

	cat <<-EOF > "${T}/provider-${P}"
	/usr/bin/rustdoc
	/usr/bin/rust-gdb
	/usr/bin/rust-lldb
	EOF
	dodir /etc/env.d/rust
	insinto /etc/env.d/rust
	doins "${T}/provider-${P}"

	rm -rf "${D}/usr/lib64/rustlib/src/"
	if use source; then
		dodir /usr/share/${P}
		cp -R "${S}/src" "${D}/usr/share/${P}"
	fi
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
