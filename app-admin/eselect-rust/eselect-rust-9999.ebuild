# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit git-r3

DESCRIPTION="eselect module for rust"
HOMEPAGE="http://github.com/jauhien/eselect-rust"
EGIT_REPO_URI="git://github.com/jauhien/eselect-rust.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""

RDEPEND="app-admin/eselect"

pkg_postinst() {
	if has_version 'dev-lang/rust'; then
		eselect rust update --if-unset
	fi
}

pkg_prerm() {
	eselect rust unset
}
