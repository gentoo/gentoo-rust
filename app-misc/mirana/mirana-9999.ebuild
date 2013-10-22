# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"
inherit git-2

DESCRIPTION="Mirana sync util"
EGIT_REPO_URI="git://github.com/Heather/Mirana.git"
HOMEPAGE="https://github.com/Heather/Mirana"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND=">=dev-lang/rust-0.9"
RDEPEND="${DEPEND}"

src_install() {
	emake DESTDIR="${D}" install || die "Install failed"
}
