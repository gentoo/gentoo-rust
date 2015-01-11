# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

PYTHON_COMPAT=( python{2_6,2_7} )

inherit eutils python-any-r1

MY_PV="rustc-1.0.0-alpha"
DESCRIPTION="Systems programming language from Mozilla"
HOMEPAGE="http://www.rust-lang.org/"

SRC_URI="http://static.rust-lang.org/dist/${MY_PV}-src.tar.gz"

LICENSE="|| ( MIT Apache-2.0 ) BSD-1 BSD-2 BSD-4 UoI-NCSA"
SLOT="1.0"
KEYWORDS="~amd64 ~x86"

IUSE="clang debug emacs libcxx +system-llvm vim-syntax zsh-completion"
REQUIRED_USE="libcxx? ( clang )"

CDEPEND="libcxx? ( sys-libs/libcxx )
	>=app-admin/eselect-rust-0.2_pre20141128
	!dev-lang/rust:0
"
DEPEND="${CDEPEND}
	${PYTHON_DEPS}
	>=dev-lang/perl-5.0
	net-misc/wget
	clang? ( sys-devel/clang )
	system-llvm? ( >=sys-devel/llvm-3.6.0[multitarget(-)] )
"
RDEPEND="${CDEPEND}
	emacs? ( >=app-emacs/rust-mode-${PV} )
	vim-syntax? ( >=app-vim/rust-mode-${PV} )
	zsh-completion? ( >=app-shells/rust-zshcomp-${PV} )
"

S=${WORKDIR}/${MY_PV}

src_prepare() {
	epatch "${FILESDIR}/${PN}-0.13.0-no-ldconfig.patch"

	local postfix="gentoo-${SLOT}"
	sed -i -e "s/CFG_FILENAME_EXTRA=.*/CFG_FILENAME_EXTRA=${postfix}/" mk/main.mk || die
}

src_configure() {
	use amd64 && ARCH_POSTFIX="x86_64"
	use x86 && ARCH_POSTFIX="i686"
	LOCAL_RUST_PATH="${WORKDIR}/rust-1.0.0-alpha-${ARCH_POSTFIX}-unknown-linux-gnu/bin"

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
	mv "${D}/usr/bin/rust-gdb" "${D}/usr/bin/rust-gdb-${PV}" || die

	dodoc COPYRIGHT LICENSE-APACHE LICENSE-MIT

	rm "${D}/usr/share/doc/rust" -rf

	# le kludge that fixes https://github.com/Heather/gentoo-rust/issues/41
	mv "${D}/usr/lib/rust-${PV}/rust-${PV}/rustlib"/* "${D}/usr/lib/rust-${PV}/rustlib/"
	rmdir "${D}/usr/lib/rust-${PV}/rust-${PV}/rustlib"
	mv "${D}/usr/lib/rust-${PV}/rust-${PV}/"/* "${D}/usr/lib/rust-${PV}/"
	rmdir "${D}/usr/lib/rust-${PV}/rust-${PV}/"

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

	elog "Rust installs a helper script for calling GDB now,"
	elog "for your convenience it is installed under /usr/bin/rust-gdb-${PV}."
}

pkg_postrm() {
	eselect rust unset --if-invalid
}
