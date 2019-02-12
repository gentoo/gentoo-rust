# Copyright 1999-2019 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cargo git-r3

CARGO_FETCH_CRATES=yes

DESCRIPTION="Cardano CLI"
HOMEPAGE="https://github.com/input-output-hk/cardano-cli"
EGIT_REPO_URI="https://github.com/input-output-hk/cardano-cli.git"
EGIT_COMMIT="v${PV}"
EGIT_SUBMODULES=( '*' )
RESTRICT="mirror"
LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
DEPEND="dev-vcs/git"
RDEPEND="${DEPEND}"
