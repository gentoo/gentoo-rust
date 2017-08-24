# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cargo git-r3

EGIT_REPO_URI="https://github.com/rust-lang-nursery/rust-clippy.git"

DESCRIPTION="A collection of lints to catch common mistakes and improve your Rust code."
HOMEPAGE="https://github.com/rust-lang-nursery/rust-clippy"
SRC_URI=""

LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"
