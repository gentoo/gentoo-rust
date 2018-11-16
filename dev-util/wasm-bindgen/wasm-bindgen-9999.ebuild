# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cargo git-r3

CARGO_FETCH_CRATES=yes

DESCRIPTION="High-level interactions between wasm modules and JS"
HOMEPAGE="https://github.com/rustwasm/wasm-bindgen"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="0"
KEYWORDS=""
RESTRICT="network-sandbox"
IUSE=""

EGIT_REPO_URI="https://github.com/rustwasm/wasm-bindgen"

COMMON_DEPEND=">=virtual/rust-9999"
DEPEND="${COMMON_DEPEND}"
RDEPEND="${COMMON_DEPEND}"

src_compile() {
	cargo build --release --manifest-path crates/cli/Cargo.toml
}

src_install() {
	dobin target/release/wasm-bindgen
	dobin target/release/wasm2es6js
}
