# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit vim-plugin git-r3

DESCRIPTION="vim plugin: racer support"
HOMEPAGE="https://github.com/racer-rust/vim-racer"
LICENSE="MIT"
KEYWORDS=""
IUSE=""
EGIT_REPO_URI="https://github.com/racer-rust/vim-racer"
RDEPEND="dev-util/racer"

src_prepare() {
	sed -i 's|\(g:racer_cmd = \).*|\1"/usr/bin/racer"|' plugin/racer.vim
}

pkg_postinst() {
	vim-plugin_pkg_postinst

	elog "For vim you can use  'let \$RUST_SRC_PATH=\"<path-to>/rust/src/\"'"
	elog "if you don't want to use environment variable"
	elog "You also can use \"set hidden\" or else your buffer will be"
	elog "unloaded on every goto-definition"
}
