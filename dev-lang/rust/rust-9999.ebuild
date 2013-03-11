# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit git-2 eutils

DESCRIPTION="Open source programming language from Mozilla"
HOMEPAGE="http://www.rust-lang.org/"
EGIT_REPO_URI="git://github.com/mozilla/rust.git"

LICENSE="AGPL-3"
SLOT="0"
KEYWORDS=""
IUSE=""
DEPEND="
	>=dev-lang/python-2.6
	>=dev-lang/perl-5.0"
RDEPEND="${DEPEND}"

src_configure() {
	./configure --prefix=/usr
}

pkg_postinst() {
	rm -f "/usr/lib/librusti.so"
	rm -f "/usr/lib/librustc.so"
	rm -f "/usr/lib/librust.so"
	rm -f "/usr/lib/librustpkg.so"
	rm -f "/usr/lib/librustdoc.so"
}
