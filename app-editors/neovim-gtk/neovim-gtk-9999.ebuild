# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cargo git-r3

DESCRIPTION="GTK UI for Neovim"
HOMEPAGE=""
SRC_URI=""

LICENSE="GPL3"
SLOT="0"
KEYWORDS=""
IUSE=""

EGIT_REPO_URI="https://github.com/daa84/neovim-gtk.git"

RDEPEND="
	app-editors/neovim
	x11-libs/gtk+:3
	x11-libs/vte:2.91
	"
DEPEND="${DEPEND}
	virtual/rust:*
	dev-util/cargo"