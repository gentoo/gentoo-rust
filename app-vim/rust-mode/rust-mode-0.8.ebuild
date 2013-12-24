# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit vim-plugin

DESCRIPTION="vim plugin: syntax highlighting, indentation, quickfix and other useful things for editing Rust code"
HOMEPAGE="http://www.rust-lang.org/"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="0"
KEYWORDS="~amd64 ~x86"

if [[ ${PV} != 9999 ]]; then
	MY_P="rust-${PV}"
	SRC_URI="http://static.rust-lang.org/dist/${MY_P}.tar.gz"

	S="${WORKDIR}/${MY_P}/src/etc/vim"
else
	EGIT_SOURCEDIR="${S}"
	S="${S}/src/etc/vim"

	inherit git-2

	EGIT_REPO_URI="git://github.com/mozilla/rust.git"
fi

src_configure() {
	echo "just for suppressing econf"
}
