# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils git-r3

DESCRIPTION="A Rust's package manager"
HOMEPAGE="http://crates.io/"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="0"
KEYWORDS=""

IUSE=""

EGIT_REPO_URI="git://github.com/rust-lang/cargo.git"

DEPEND="=dev-lang/rust-9999"
RDEPEND="${DEPEND}"

src_configure() {
	"${ECONF_SOURCE:-.}"/configure \
		--prefix="${EPREFIX}"/usr \
		--local-rust-root="${EPREFIX}"/usr \
	|| die
}

src_install() {
	emake DESTDIR="${D}" install || die
}
