# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit git-r3

DESCRIPTION="Rust zsh completions"
HOMEPAGE="http://www.rust-lang.org/"
EGIT_REPO_URI="https://github.com/rust-lang/zsh-config"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="0"

DEPEND="app-shells/zsh"
RDEPEND="${DEPEND}"

src_install() {
	insinto /usr/share/zsh/site-functions
	doins _rust
}
