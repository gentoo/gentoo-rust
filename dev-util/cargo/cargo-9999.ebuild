# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils bash-completion-r1 git-r3

DESCRIPTION="The Rust's package manager"
HOMEPAGE="http://crates.io/"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="0"
KEYWORDS=""
RESTRICT="network-sandbox"

IUSE="libressl"

EGIT_REPO_URI="https://github.com/rust-lang/cargo.git"
BIN_CARGO_URI="https://static.rust-lang.org/dist/cargo-nightly"

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

DOCS="LICENSE-APACHE LICENSE-MIT LICENSE-THIRD-PARTY README.md"

pkg_setup() {
	local postfix
	use amd64 && postfix=x86_64-unknown-linux-gnu
	use x86 && postfix=i686-unknown-linux-gnu

	# Download nightly cargo to bootstrap from it

	wget "${BIN_CARGO_URI}-${postfix}.tar.gz" || die
	unpack "./cargo-nightly-${postfix}.tar.gz"
	mv "./cargo-nightly-${postfix}" "./cargo"
}

src_compile() {
	"$HOME/cargo/cargo/bin/cargo" build --release || die
}

src_install() {
	default
	dobin target/release/${PN}
	doman src/etc/man/${PN}*.1
	newbashcomp src/etc/cargo.bashcomp.sh cargo
	insinto /usr/share/zsh/site-functions
	doins src/etc/_cargo
}
