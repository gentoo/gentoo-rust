# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit git-2

DESCRIPTION="Open source programming language from Mozilla"
HOMEPAGE="http://www.rust-lang.org/"
EGIT_REPO_URI="git://github.com/mozilla/rust.git"

LICENSE="MIT Apache-2.0"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="clang"

RDEPEND="sys-devel/llvm"
DEPEND="${RDEPEND}
	clang? ( sys-devel/clang )
	>=dev-lang/perl-5.0
	>=dev-lang/python-2.6
"

src_configure() {
	${ECONF_SOURCE:-.}/configure \
		$(use_enable clang)         \
		--prefix=${EPREFIX}/usr               \
		--local-rust-root=${EPREFIX}/usr      \
	|| die
}
 
src_compile() {
	emake || die
}
 
src_install() {
	emake DESTDIR="${D}" install || die
}

pkg_postinst() {
	rm -f "/usr/lib/librusti.so"
	rm -f "/usr/lib/librustc.so"
	rm -f "/usr/lib/librust.so"
	rm -f "/usr/lib/librustpkg.so"
	rm -f "/usr/lib/librustdoc.so"
}
