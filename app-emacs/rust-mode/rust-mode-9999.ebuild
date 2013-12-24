# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit elisp

DESCRIPTION="Emacs major mode for editing Rust code"
HOMEPAGE="http://www.rust-lang.org/"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="0"
KEYWORDS=""

if [[ ${PV} != 9999 ]]; then
	MY_P="rust-${PV}"
	SRC_URI="http://static.rust-lang.org/dist/${MY_P}.tar.gz"

	S="${WORKDIR}/${MY_P}/src/etc/emacs"
else
	EGIT_SOURCEDIR="${S}"
	S="${S}/src/etc/emacs"

	inherit git-2

	EGIT_REPO_URI="git://github.com/mozilla/rust.git"
fi

SITEFILE="50${PN}-gentoo.el"
