# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils bash-completion-r1 git-r3

DESCRIPTION="A Rust's package manager"
HOMEPAGE="http://crates.io/"

# version of cargo binary to bootstrap with
SNAPSHOT_DATE="2015-04-02"

SRC_URI="
	x86?   ( https://static-rust-lang-org.s3.amazonaws.com/cargo-dist/${SNAPSHOT_DATE}/cargo-nightly-i686-unknown-linux-gnu.tar.gz ->
		cargo-nightly-i686-unknown-linux-gnu-${SNAPSHOT_DATE}.tar.gz )
	amd64? ( https://static-rust-lang-org.s3.amazonaws.com/cargo-dist/${SNAPSHOT_DATE}/cargo-nightly-x86_64-unknown-linux-gnu.tar.gz ->
		cargo-nightly-x86_64-unknown-linux-gnu-${SNAPSHOT_DATE}.tar.gz )"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE=""

EGIT_REPO_URI="https://github.com/rust-lang/cargo.git"
EGIT_COMMIT="${PV}"

COMMON_DEPEND=">=virtual/rust-1.0
	sys-libs/zlib
	dev-libs/openssl:*
	net-libs/libssh2
	net-libs/http-parser"
RDEPEND="${COMMON_DEPEND}
	net-misc/curl[curl_ssl_openssl]"
DEPEND="${COMMON_DEPEND}
	dev-util/cmake"

src_unpack() {
	git-r3_checkout
	unpack "${A}"
	mv cargo-nightly-*-unknown-linux-gnu "cargo-snapshot"
}

src_configure() {
	./configure --prefix="${EPREFIX}"/usr --disable-verify-install \
		--local-cargo="${WORKDIR}/cargo-snapshot/cargo/bin/cargo" || die
}

src_install() {
	CFG_DISABLE_LDCONFIG="true" emake DESTDIR="${D}" install || die
	dobashcomp "${ED}"/usr/etc/bash_completion.d/cargo
	rm -rf "${ED}"/usr/etc
}
