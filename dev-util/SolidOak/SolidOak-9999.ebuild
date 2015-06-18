# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils git-r3

DESCRIPTION="An IDE for Rust"
HOMEPAGE="https://sekao.net/solidoak/"
SRC_URI=""

LICENSE="public-domain"
SLOT="0"
KEYWORDS=""
IUSE=""

EGIT_REPO_URI="https://github.com/oakes/SolidOak.git"

RDEPEND="dev-lang/rust:*
	dev-util/racer
	x11-libs/vte
	app-editors/neovim
	>=x11-libs/gtk+-3.10
	"
DEPEND="${DEPEND}
	dev-rust/cargo"

src_compile() {
	cargo build --release -j5 || die
}

src_install() {
	dobin target/release/solidoak || die
	doicon ${S}/resources/solidoak.svg
	domenu ${S}/resources/SolidOak.desktop
}
