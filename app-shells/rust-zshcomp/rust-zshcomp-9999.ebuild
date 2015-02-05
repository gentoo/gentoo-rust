# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit git-r3

DESCRIPTION="Rust zsh completions"
HOMEPAGE="http://www.rust-lang.org/"
EGIT_REPO_URI="https://github.com/rust-lang/zsh-config"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="0"

DEPEND="app-shells/zsh
	!!<=app-admin/eselect-rust-0.1_pre20140820
	!<=dev-lang/rust-0.11.0-r1:0.11
	!<=dev-lang/rust-999:nightly
	!<=dev-lang/rust-9999-r2:git
"
RDEPEND="${DEPEND}"

src_install() {
	insinto /usr/share/zsh/site-functions
	doins _rust
}
