# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cargo

CARGO_FETCH_CRATES=yes

DESCRIPTION="sccache is ccache with cloud storage"
HOMEPAGE="https://github.com/mozilla/sccache"
SRC_URI="https://github.com/mozilla/sccache/archive/${PV}.tar.gz -> ${P}.tar.gz
	$(cargo_crate_uris ${CRATES})"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="dev-lang/rust"
RDEPEND=""

src_unpack() {
	cargo_src_unpack
	default
}
