# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit meson vala git-r3

DESCRIPTION="A GTK+ front-end for the Xi editor"
HOMEPAGE="https://github.com/eyelash/xi-gtk"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS=""
IUSE=""
RESTRICT="network-sandbox"

EGIT_REPO_URI="https://github.com/eyelash/xi-gtk.git"

DEPEND="$(vala_depend)
	>=x11-libs/gtk+-3.20.0
	dev-libs/json-glib"
RDEPEND="${DEPEND}
	~app-editors/xi-core-9999"

PATCHES=(
	"${FILESDIR}/xi-gtk-9999-datasubdir.patch"
)

src_prepare() {
	default
	vala_src_prepare
}

src_configure() {
	local emesonargs=(
		-Ddatasubdir="xi"
	)
	meson_src_configure
}
