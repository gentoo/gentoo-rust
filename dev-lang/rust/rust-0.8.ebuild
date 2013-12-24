# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit multilib

DESCRIPTION="Open source programming language from Mozilla"
HOMEPAGE="http://www.rust-lang.org/"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="0"
KEYWORDS="~amd64 ~x86"

if [[ ${PV}	!= 9999 ]]; then
	IUSE="clang debug"

	SRC_URI="http://static.rust-lang.org/dist/${P}.tar.gz"
else
	inherit git-2
	IUSE="clang +heather debug"

	if use heather; then
		EGIT_REPO_URI="git://github.com/Heather/rust.git"
	else
		EGIT_REPO_URI="git://github.com/mozilla/rust.git"
	fi
	EGIT_MASTER="master"
fi


RDEPEND="sys-devel/llvm"
DEPEND="${RDEPEND}
	clang? ( sys-devel/clang )
	>=dev-lang/perl-5.0
	>=dev-lang/python-2.6
"

src_configure() {
	"${ECONF_SOURCE:-.}"/configure \
		--prefix="${EPREFIX}"/usr \
		$(use_enable clang) \
		$(use_enable debug) \
		--local-rust-root="${EPREFIX}"/usr \
	|| die
}

src_install() {
	default
	rm -f "${ED}/usr/$(get_libdir)/librusti.so" || die
	rm -f "${ED}/usr/$(get_libdir)/librustc.so" || die
	rm -f "${ED}/usr/$(get_libdir)/librust.so" || die
	rm -f "${ED}/usr/$(get_libdir)/librustpkg.so" || die
	rm -f "${ED}/usr/$(get_libdir)/librustdoc.so" || die
}
