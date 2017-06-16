# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit elisp git-r3

DESCRIPTION="A major emacs mode for editing Rust source code"
HOMEPAGE="http://www.rust-lang.org/"
EGIT_REPO_URI="https://github.com/rust-lang/rust-mode"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="0"

SITEFILE="50${PN}-gentoo.el"
