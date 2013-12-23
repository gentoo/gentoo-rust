# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit multilib

DESCRIPTION="Opensource programming language from Mozilla"
HOMEPAGE="http://www.rust-lang.org"
SRC_URI="http://static.rust-lang.org/dist/${P}.tar.gz"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="clang debug"

RDEPEND="sys-devel/llvm"
DEPEND="${RDEPEND}
	clang? ( sys-devel/clang )
	>=dev-lang/perl-5.0
	>=dev-lang/python-2.6"

src_configure() {
	"${ECONF_SOURCE:-.}"/configure \
		--prefix="${EPREFIX}"/usr \
		$(use_enable clang) \
		$(use_enable debug) \
		--local-rust-root="${EPREFIX}"/usr \
	|| die "configure failed"
}

src_install() {
	default
	rm -f "${ED}/usr/$(get_libdir)/librusti.so" || die
	rm -f "${ED}/usr/$(get_libdir)/librustc.so" || die
	rm -f "${ED}/usr/$(get_libdir)/librust.so" || die
	rm -f "${ED}/usr/$(get_libdir)/librustpkg.so" || die
	rm -f "${ED}/usr/$(get_libdir)/librustdoc.so" || die
}
