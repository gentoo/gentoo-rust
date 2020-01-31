# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit eutils git-r3

DESCRIPTION="Rust Code Completion utility "
HOMEPAGE="https://github.com/phildawes/racer"

LICENSE="MIT"
SLOT="0"
KEYWORDS=""
RESTRICT="network-sandbox"
IUSE=""

EGIT_REPO_URI="https://github.com/phildawes/racer"

COMMON_DEPEND="virtual/rust:*"
DEPEND="${COMMON_DEPEND}"
RDEPEND="${COMMON_DEPEND}"

src_compile() {
	cargo build --release
}

src_install() {
	dobin target/release/racer
}

pkg_postinst() {
	elog "You most probably should fetch rust sources for best expirience."
	elog "Racer will look for sources in path pointed by RUST_SRC_PATH"
	elog "environment variable. You can use"
	elog "% export RUST_SRC_PATH=<path to>/rust/src."
	elog "Use vim-racer or emacs-racer for the editos support"
	elog
}
