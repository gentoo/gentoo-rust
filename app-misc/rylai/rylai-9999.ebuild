# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"
inherit git-2

DESCRIPTION="Rylai sync util"
EGIT_REPO_URI="git://github.com/Heather/Rylai.git"
HOMEPAGE="https://github.com/Heather/Rylai"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND=">=dev-lang/rust-0.8"
RDEPEND="${DEPEND}"

src_install() {
	emake DESTDIR="${D}" install || die "Install failed"
}
