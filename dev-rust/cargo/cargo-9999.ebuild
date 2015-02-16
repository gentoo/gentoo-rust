# Copyright 1999-2015 Gentoo Foundation
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

EGIT_REPO_URI="https://github.com/rust-lang/cargo.git"

RDEPEND=">=virtual/rust-999"
DEPEND="${DEPEND}
	dev-util/cmake"

src_prepare() {
	use x86 && export BITS=32
	CFG_DISABLE_LDCONFIG="nonempty" ./.travis.install.deps.sh || die
}

src_configure() {
	./configure \
		--local-rust-root="${PWD}/rustc" \
		--prefix="${EPREFIX}"/usr \
		--disable-verify-install \
	|| die
}

src_install() {
	CFG_DISABLE_LDCONFIG="true" emake DESTDIR="${D}" install || die
}
