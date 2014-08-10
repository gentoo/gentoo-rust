# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

PYTHON_COMPAT=( python{2_6,2_7} )

inherit elisp-common eutils git-r3 python-any-r1

DESCRIPTION="Systems programming language from Mozilla"
HOMEPAGE="http://www.rust-lang.org/"

if use heather; then
	EGIT_REPO_URI="git://github.com/Heather/rust.git"
else
	EGIT_REPO_URI="git://github.com/rust-lang/rust.git"
fi

LICENSE="|| ( MIT Apache-2.0 ) BSD-1 BSD-2 BSD-4 UoI-NCSA"
SLOT="0"
KEYWORDS=""

IUSE="clang debug emacs heather libcxx vim-syntax zsh-completion"
REQUIRED_USE="libcxx? ( clang )"

RDEPEND="vim-syntax? ( || ( app-editors/vim app-editors/gvim ) )
	zsh-completion? ( app-shells/zsh )"
DEPEND="${RDEPEND}
	${PYTHON_DEPS}
	>=dev-lang/perl-5.0
	clang? ( sys-devel/clang )
	emacs? ( virtual/emacs )
	libcxx? ( sys-libs/libcxx )"

SITEFILE="50${PN}-mode-gentoo.el"

src_unpack() {
	git-r3_src_unpack

	use amd64 && BUILD_TRIPLE=x86_64-unknown-linux-gnu
	use x86 && BUILD_TRIPLE=i686-unknown-linux-gnu
	export CFG_SRC_DIR="${S}" && \
		cd ${S} && \
		mkdir -p "${S}/dl" && \
		mkdir -p "${S}/${BUILD_TRIPLE}/stage0/bin" && \
		python2 "${S}/src/etc/get-snapshot.py" ${BUILD_TRIPLE} || die
}

src_prepare() {
	epatch "${FILESDIR}/${PN}-0.12.0-no-ldconfig.patch"
}

src_configure() {
	"${ECONF_SOURCE:-.}"/configure \
		--prefix="${EPREFIX}/usr/" \
		$(use_enable clang) \
		$(use_enable debug) \
		$(use_enable debug llvm-assertions) \
		$(use_enable !debug optimize) \
		$(use_enable !debug optimize-cxx) \
		$(use_enable !debug optimize-llvm) \
		$(use_enable !debug optimize-tests) \
		$(use_enable libcxx libcpp) \
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
