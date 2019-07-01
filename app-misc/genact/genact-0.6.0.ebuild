# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cargo

CARGO_FETCH_CRATES=yes

DESCRIPTION="A nonsense activity generator"
HOMEPAGE="https://github.com/svenstaro/genact"
SRC_URI="https://github.com/svenstaro/genact/archive/${PV}.tar.gz"
RESTRICT="mirror"
LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
DEPEND=""
RDEPEND="${DEPEND}"
