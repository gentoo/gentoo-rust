# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

PYTHON_COMPAT=( python2_7 )

inherit eutils git-r3 multilib python-any-r1

if [[ ${PV} = 9999 ]]; then
	SLOT="git"
	release_channel="dev"
	MY_P="rust-git"
	EGIT_REPO_URI="https://github.com/rust-lang/rust.git"
	EGIT_CHECKOUT_DIR="${MY_P}-src"
else
	SLOT="nightly"
	release_channel="${SLOT}"
	MY_P="rustc-nightly"
	MY_SRC_URI="http://static.rust-lang.org/dist/${MY_P}-src.tar.gz"
fi

DESCRIPTION="Systems programming language from Mozilla"
HOMEPAGE="http://www.rust-lang.org/"

LICENSE="|| ( MIT Apache-2.0 ) BSD-1 BSD-2 BSD-4 UoI-NCSA"
KEYWORDS=""

IUSE="clang debug doc libcxx source +system-llvm"
REQUIRED_USE="libcxx? ( clang )"

CDEPEND="libcxx? ( sys-libs/libcxx )
	>=app-eselect/eselect-rust-0.3_pre20150425
	!dev-lang/rust:0
"
DEPEND="${CDEPEND}
	${PYTHON_DEPS}
	>=dev-lang/perl-5.0
	net-misc/wget
	clang? ( sys-devel/clang )
"
RDEPEND="${CDEPEND}
"

S="${WORKDIR}/${MY_P}-src"

pkg_setup() {
	if use system-llvm; then
		EGIT_SUBMODULES=( "*" "-src/llvm" )
	fi
}

src_unpack() {
	if [[ ${PV} = 9999 ]]; then
		git-r3_src_unpack
	else
		wget "${MY_SRC_URI}" || die
		unpack ./"${MY_P}-src.tar.gz"
	fi

	use amd64 && BUILD_TRIPLE=x86_64-unknown-linux-gnu
	use x86 && BUILD_TRIPLE=i686-unknown-linux-gnu
}

src_configure() {
	# We need to ask llvm-config to link to dynamic libraries
	# because LLVM ebuild does not provide an option
	# to compile static libraries
	if use system-llvm; then
		export LLVM_LINK_SHARED=1
	fi

	python_setup

	export CFG_DISABLE_LDCONFIG="notempty"

	local postfix="gentoo-${SLOT}"
	local stagename="RUST_STAGE0_${ARCH}"
	local stage0="${!stagename}"

	"${ECONF_SOURCE:-.}"/configure \
		--prefix="${EPREFIX}/usr" \
		--libdir="${EPREFIX}/usr/$(get_libdir)/${P}" \
		--mandir="${EPREFIX}/usr/share/${P}/man" \
		--release-channel=${release_channel%%/*} \
		--extra-filename=${postfix} \
		--disable-manage-submodules \
		--default-linker=$(tc-getBUILD_CC) \
		--default-ar=$(tc-getBUILD_AR) \
		--python=${EPYTHON} \
		--disable-rpath \
		--build=${BUILD_TRIPLE} \
		$(use_enable clang) \
		$(use_enable debug) \
		$(use_enable debug llvm-assertions) \
		$(use_enable !debug optimize) \
		$(use_enable !debug optimize-cxx) \
		$(use_enable !debug optimize-llvm) \
		$(use_enable !debug optimize-tests) \
		$(use_enable doc docs) \
		$(use_enable libcxx libcpp) \
		|| die
}

src_compile() {
	emake dist VERBOSE=1
}

src_install() {
	default

	mv "${D}/usr/bin/rustc" "${D}/usr/bin/rustc-${PV}" || die
	mv "${D}/usr/bin/rustdoc" "${D}/usr/bin/rustdoc-${PV}" || die
	mv "${D}/usr/bin/rust-gdb" "${D}/usr/bin/rust-gdb-${PV}" || die
	mv "${D}/usr/bin/rust-lldb" "${D}/usr/bin/rust-lldb-${PV}" || die

	dodoc COPYRIGHT LICENSE-APACHE LICENSE-MIT

	dodir "/usr/share/doc/rust-${PV}/"
	mv "${D}/usr/share/doc/rust"/* "${D}/usr/share/doc/rust-${PV}/" || die
	rmdir "${D}/usr/share/doc/rust/" || die

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
