# Copyright 2012 Funtoo Technologies
# Distributed under the terms of the GNU General Public License v2

EAPI=5
PYTHON_RESTRICTED_ABIS="3.*"

inherit python

DESCRIPTION="Experimental programming language from mozilla"
HOMEPAGE="http://www.rust-lang.org"
SRC_URI="http://static.rust-lang.org/dist/${P}.tar.gz"

LICENSE="MIT Apache-2.0"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="clang"

RDEPEND="sys-devel/llvm"
DEPEND="${RDEPEND}
	clang? ( sys-devel/clang )
	dev-lang/perl
	dev-lang/python
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
