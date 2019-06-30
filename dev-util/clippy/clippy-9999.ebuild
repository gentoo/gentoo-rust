# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cargo git-r3

CARGO_FETCH_CRATES=yes

EGIT_REPO_URI="https://github.com/rust-lang-nursery/rust-clippy.git"

DESCRIPTION="A collection of lints to catch common mistakes and improve your Rust code."
HOMEPAGE="https://github.com/rust-lang-nursery/rust-clippy"
SRC_URI=""

LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND=">=virtual/rust-9999"
RDEPEND="${DEPEND}"

src_install() {
	debug-print-function ${FUNCNAME} "$@"

	cargo install -j $(makeopts_jobs) --root="${D}/usr" --path .  $(usex debug --debug "") \
	|| die "cargo install failed"
	rm -f "${D}/usr/.crates.toml"

	[ -d "${S}/man" ] && doman "${S}/man" || return
}
