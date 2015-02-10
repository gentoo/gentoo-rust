# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit vim-plugin

MY_PV="rustc-1.0.0-alpha"
DESCRIPTION="Rust mode for vim"
HOMEPAGE="http://www.rust-lang.org/"
SRC_URI="http://static.rust-lang.org/dist/${MY_PV}-src.tar.gz"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="0"
KEYWORDS="~amd64 ~x86"

S="${WORKDIR}/${MY_PV}/src/etc/vim"
