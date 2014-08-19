# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

DESCRIPTION="eselect module for rust"
HOMEPAGE="http://github.com/jauhien/eselect-rust"
SRC_URI="https://github.com/jauhien/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="app-admin/eselect"
