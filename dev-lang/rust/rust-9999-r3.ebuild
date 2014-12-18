# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

PYTHON_COMPAT=( python{2_6,2_7} )

inherit eutils git-r3 python-any-r1

DESCRIPTION="Systems programming language from Mozilla"
HOMEPAGE="http://www.rust-lang.org/"
EGIT_REPO_URI="git://github.com/rust-lang/rust.git"

LICENSE="|| ( MIT Apache-2.0 ) BSD-1 BSD-2 BSD-4 UoI-NCSA"
SLOT="git"
KEYWORDS=""

IUSE="clang debug emacs libcxx +system-llvm vim-syntax zsh-completion"
REQUIRED_USE="libcxx? ( clang )"

CDEPEND="libcxx? ( sys-libs/libcxx )
	>=app-admin/eselect-rust-0.2_pre20141128
	!dev-lang/rust:0
"
DEPEND="${CDEPEND}
	${PYTHON_DEPS}
	>=dev-lang/perl-5.0
	clang? ( sys-devel/clang )
	system-llvm? ( >=sys-devel/llvm-3.6.0[multitarget(-)] )
"
RDEPEND="${CDEPEND}
	emacs? ( >=app-emacs/rust-mode-${PV} )
	vim-syntax? ( >=app-vim/rust-mode-${PV} )
	zsh-completion? ( >=app-shells/rust-zshcomp-${PV} )
"

src_unpack() {
	git-r3_src_unpack

	use amd64 && BUILD_TRIPLE=x86_64-unknown-linux-gnu
	use x86 && BUILD_TRIPLE=i686-unknown-linux-gnu
	export CFG_SRC_DIR="${S}" && \
		cd ${S} && \
		mkdir -p "${S}/dl" && \
		mkdir -p "${S}/${BUILD_TRIPLE}/stage0/bin" && \
		python2 "${S}/src/etc/get-snapshot.py" ${BUILD_TRIPLE} || die
}

src_prepare() {
	epatch "${FILESDIR}/${PN}-0.13.0-no-ldconfig.patch"

	local postfix="gentoo-${SLOT}"
	sed -i -e "s/CFG_FILENAME_EXTRA=.*/CFG_FILENAME_EXTRA=${postfix}/" mk/main.mk || die
}

src_configure() {
	local system_llvm
	use system-llvm && system_llvm="--llvm-root=${EPREFIX}/usr"

	"${ECONF_SOURCE:-.}"/configure \
		--prefix="${EPREFIX}/usr" \
		--libdir="${EPREFIX}/usr/lib/${P}" \
		--mandir="${EPREFIX}/usr/share/${P}/man" \
		$(use_enable clang) \
		$(use_enable debug) \
		$(use_enable debug llvm-assertions) \
		$(use_enable !debug optimize) \
		$(use_enable !debug optimize-cxx) \
		$(use_enable !debug optimize-llvm) \
		$(use_enable !debug optimize-tests) \
		$(use_enable libcxx libcpp) \
		${system_llvm} \
		--disable-manage-submodules \
		--disable-verify-install \
		--disable-docs \
		|| die
}

src_compile() {
	emake VERBOSE=1
}

src_install() {
	default

	mv "${D}/usr/bin/rustc" "${D}/usr/bin/rustc-${PV}" || die
	mv "${D}/usr/bin/rustdoc" "${D}/usr/bin/rustdoc-${PV}" || die
	mv "${D}/usr/bin/rust-lldb" "${D}/usr/bin/rust-lldb-${PV}" || die

	cat <<-EOF > "${T}"/50${P}
	LDPATH="/usr/lib/${P}"
	MANPATH="/usr/share/${P}/man"
	EOF
	doenvd "${T}"/50${P}

	dodir /etc/env.d/rust
	touch "${D}/etc/env.d/rust/provider-${P}" || die
}

pkg_postinst() {
	eselect rust update --if-unset

	elog "Rust uses slots now, use 'eselect rust list'"
	elog "and 'eselect rust set' to list and set rust version."
	elog "For more information see 'eselect rust help'"
	elog "and http://wiki.gentoo.org/wiki/Project:Eselect/User_guide"

	elog "Rust installs a helper script for calling LLDB now,"
	elog "for your convenience it is installed under /usr/bin/rust-lldb-${PV},"
	elog "but note, that there is no LLDB ebuild in the tree currently,"
	elog "so you are on your own if you want to use it."
}

pkg_postrm() {
	eselect rust unset --if-invalid
}
