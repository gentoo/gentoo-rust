# Copyright 2017-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cargo

CARGO_FETCH_CRATES=yes

DESCRIPTION="Cargo subcommand that visualizes a crate's dependency graph in a tree-like format"
HOMEPAGE="https://github.com/sfackler/cargo-tree"
SRC_URI="https://github.com/sfackler/cargo-tree/archive/v${PV}.tar.gz"
RESTRICT="mirror"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=""
RDEPEND=""
