# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cargo eutils git-r3

DESCRIPTION="An IDE for Rust"
HOMEPAGE="https://sekao.net/solidoak/"
SRC_URI=""

LICENSE="public-domain"
SLOT="0"
KEYWORDS=""
IUSE=""
RESTRICT="network-sandbox"

EGIT_REPO_URI="https://github.com/oakes/SolidOak.git"

RDEPEND="virtual/rust
	dev-util/racer
	x11-libs/vte:2.91
	app-editors/neovim
	>=x11-libs/gtk+-3.10
	"
DEPEND="${DEPEND}"

src_compile() {
	cargo build -j$(makeopts_jobs) --release || die
}

src_install() {
	dobin target/release/solidoak || die
	doicon "${S}/resources/solidoak.svg"
	domenu "${S}/resources/SolidOak.desktop"
}
