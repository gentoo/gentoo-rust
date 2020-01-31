# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cargo git-r3

CARGO_FETCH_CRATES=yes

EGIT_REPO_URI="https://github.com/rust-qt/cpp_to_rust.git"

DESCRIPTION="Generator of Rust-Qt crates."
HOMEPAGE="https://github.com/rust-qt/cpp_to_rust"
SRC_URI=""

LICENSE="MIT"
SLOT="0"
KEYWORDS=""
IUSE=""

CDEPEND="dev-db/sqlite"
DEPEND="${CDEPEND}
virtual/rust
"
RDEPEND="${CDEPEND}
dev-qt/qtchooser
dev-qt/qtcore
"

S="${WORKDIR}/${P}/qt_generator/qt_generator"
