# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo git-r3

CARGO_FETCH_CRATES=yes

DESCRIPTION="A modern editor with a backend written in Rust"
HOMEPAGE="https://xi-editor.github.io/xi-editor/"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS=""
IUSE="+syntect"
RESTRICT="network-sandbox"

EGIT_REPO_URI="https://github.com/xi-editor/xi-editor.git"

DEPEND=""
RDEPEND=""

S=${WORKDIR}/${P}/rust

src_compile() {
	debug-print-function ${FUNCNAME} "$@"

	export CARGO_HOME="${ECARGO_HOME}"

	cargo build -v -j $(makeopts_jobs) $(usex debug "" --release) \
		|| die "cargo build failed"

	if use syntect; then
		cargo build -v -j $(makeopts_jobs) $(usex debug "" --release) --manifest-path syntect-plugin/Cargo.toml \
			|| die "cargo build failed"
	fi
}

src_install() {
	einfo "PWD = $(pwd)"
	debug-print-function ${FUNCNAME} "$@"

	cargo install --path . -j $(makeopts_jobs) --root="${D}/usr" $(usex debug --debug "") \
		|| die "cargo install failed"
	rm -f "${D}/usr/.crates.toml"

	if use syntect; then
		insinto /usr/share/xi/plugins/syntect
		doins syntect-plugin/manifest.toml
		exeinto /usr/share/xi/plugins/syntect/bin
		doexe target/release/xi-syntect-plugin
	fi
}
