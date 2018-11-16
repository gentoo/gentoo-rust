# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit eutils git-r3

DESCRIPTION="Create ctags/etags for a cargo project and all of its dependencies"
HOMEPAGE="https://github.com/dan-t/rusty-tags"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS=""
IUSE=""

EGIT_REPO_URI="https://github.com/dan-t/rusty-tags.git"

RDEPEND="virtual/rust:*"
DEPEND="${DEPEND}"

src_compile() {
	cargo build --release || die
}

src_install() {
	dobin target/release/rusty-tags || die
	dodoc README.md
}
