# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit eutils bash-completion-r1 git-r3

DESCRIPTION="The Rust's package manager"
HOMEPAGE="http://crates.io/"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="0"
KEYWORDS=""

IUSE="libressl"

EGIT_REPO_URI="https://github.com/rust-lang/cargo.git"
BIN_CARGO_URI="http://static.rust-lang.org/dist/cargo-nightly"

COMMON_DEPEND=">=virtual/rust-999
	sys-libs/zlib
	!libressl? ( dev-libs/openssl:* )
	libressl? ( dev-libs/libressl:0 )
	net-libs/libssh2
	net-libs/http-parser"
RDEPEND="${COMMON_DEPEND}
	net-misc/curl[ssl]"
DEPEND="${COMMON_DEPEND}
	dev-util/cmake"

pkg_setup() {
	local postfix
	use amd64 && postfix=x86_64-unknown-linux-gnu
	use x86 && postfix=i686-unknown-linux-gnu

	# Download nightly cargo to bootstrap from it

	wget "${BIN_CARGO_URI}-${postfix}.tar.gz" || die
	unpack "./cargo-nightly-${postfix}.tar.gz"
}

src_configure() {
	./configure --local-rust-root="cargo-nightly-${postfix}/cargo" --prefix="${EPREFIX}"/usr --disable-verify-install || die
}

src_compile() {
	emake VERBOSE=1 PKG_CONFIG_PATH="" || die
}

src_install() {
	CFG_DISABLE_LDCONFIG="true" emake DESTDIR="${D}" install || die
	dobashcomp "${ED}"/usr/etc/bash_completion.d/cargo
	rm -rf "${ED}"/usr/etc
}
