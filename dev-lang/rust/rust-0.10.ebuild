# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

PYTHON_COMPAT=( python{2_6,2_7} )

inherit elisp-common python-any-r1

DESCRIPTION="Systems programming language from Mozilla"
HOMEPAGE="http://www.rust-lang.org/"

ARCH_SRC_URI="amd64? ( mirror://gentoo/${PN}-bin-amd64-${PV}.tbz2 )
	x86? ( mirror://gentoo/${PN}-bin-x86-${PV}.tbz2 )"
SRC_URI="http://static.rust-lang.org/dist/${P}.tar.gz
	binary-bootstrap? ( ${ARCH_SRC_URI} )"

LICENSE="|| ( MIT Apache-2.0 ) BSD-1 BSD-2 BSD-4 UoI-NCSA"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE="+binary-bootstrap clang debug emacs vim-syntax zsh-completion"

RDEPEND="emacs? ( virtual/emacs )
	vim-syntax? ( || ( app-editors/vim app-editors/gvim ) )
	zsh-completion? ( app-shells/zsh )"
DEPEND="${RDEPEND}
	${PYTHON_DEPS}
	>=dev-lang/perl-5.0
	clang? ( sys-devel/clang )"

SITEFILE="50${PN}-mode-gentoo.el"

src_configure() {
	local LOCAL_RUST_PATH=/usr
	if use binary-bootstrap; then
		LOCAL_RUST_PATH="${WORKDIR}${LOCAL_RUST_PATH}"
	else
		LOCAL_RUST_PATH="${EPREFIX}${LOCAL_RUST_PATH}"
	fi

	"${ECONF_SOURCE:-.}"/configure \
		--prefix="${EPREFIX}/usr/" \
		$(use_enable clang) \
		$(use_enable debug) \
		$(use_enable debug llvm-assertions) \
		$(use_enable !debug optimize) \
		$(use_enable !debug optimize-cxx) \
		$(use_enable !debug optimize-llvm) \
		$(use_enable !debug optimize-tests) \
		--enable-local-rust \
		--local-rust-root="${LOCAL_RUST_PATH}" \
		--disable-manage-submodules \
		|| die
}

src_compile() {
	default

	if use emacs; then
		cd src/etc/emacs || die
		elisp-compile *.el
		elisp-make-autoload-file "${PN}-mode-autoloads.el" .
	fi
}

src_install() {
	default

	if use emacs; then
		elisp-install ${PN}-mode src/etc/emacs/*.el src/etc/emacs/*.elc
		elisp-site-file-install "${FILESDIR}/${SITEFILE}"
	fi

	if use vim-syntax; then
		insinto /usr/share/vim/vimfiles
		doins -r src/etc/vim/*
	fi

	if use zsh-completion; then
		insinto "/usr/share/zsh/site-functions"
		doins src/etc/zsh/_rust
	fi
}

pkg_postinst() {
	use emacs && elisp-site-regen
}

pkg_postrm() {
	use emacs && elisp-site-regen
}
