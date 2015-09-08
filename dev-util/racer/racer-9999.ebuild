# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit eutils git-r3 elisp-common

DESCRIPTION="Rust Code Completion utility "
HOMEPAGE="https://github.com/phildawes/racer"

LICENSE="MIT"
SLOT="0"
KEYWORDS=""
IUSE="emacs vim"

EGIT_REPO_URI="https://github.com/phildawes/racer"

COMMON_DEPEND="dev-lang/rust:*
	emacs? (
		app-emacs/company-mode[ropemacs]
		app-emacs/rust-mode
		virtual/emacs )
	vim? ( || ( app-editors/vim app-editors/gvim ) )"
DEPEND="${COMMON_DEPEND}
	dev-util/cargo"
RDEPEND="${COMMON_DEPEND}"

src_compile() {
	cargo build --release
}

src_install() {
	dobin target/release/racer
	if use emacs; then
		elisp-install ${PN} editors/racer.el
		elisp-site-file-install "${FILESDIR}/50${PN}-gentoo.el"
	fi
	if use vim; then
		insinto /usr/share/vim/vimfiles/plugin/
		sed -i 's|\(g:racer_cmd = \).*|\1"/usr/bin/racer"|' plugin/racer.vim
		doins plugin/racer.vim
	fi
}

pkg_postinst() {
	elog "You most probably should fetch rust sources for best expirience."
	elog "Racer will look for sources in path pointed by RUST_SRC_PATH"
	elog "environment variable. You can use"
	elog "% export RUST_SRC_PATH=<path to>/rust/src."
	elog
	if use emacs; then
		elog "You should use '(setq racer-rust-src-path \"<path-to>/rust/src/\")'"
		elog "for emacs plugin to be able to find rust sources for racer."
		elog
		elisp-site-regen
	fi
	if use vim; then
		elog "For vim you can use  'let \$RUST_SRC_PATH=\"<path-to>/rust/src/\"'"
		elog "if you don't want to use environment variable"
		elog "You also can use \"set hidden\" or else your buffer will be"
		elog "unloaded on every goto-definition"
	fi
}

pkg_postrm() {
	use emacs && elisp-site-regen
}
