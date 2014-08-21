# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

PYTHON_COMPAT=( python{2_6,2_7} )

inherit elisp-common eutils git-r3 python-any-r1

DESCRIPTION="Systems programming language from Mozilla"
HOMEPAGE="http://www.rust-lang.org/"
EGIT_REPO_URI="git://github.com/rust-lang/rust.git"

LICENSE="|| ( MIT Apache-2.0 ) BSD-1 BSD-2 BSD-4 UoI-NCSA"
SLOT="git"
KEYWORDS=""

IUSE="clang debug emacs libcxx vim-syntax zsh-completion"
REQUIRED_USE="libcxx? ( clang )"

RDEPEND="vim-syntax? ( || ( app-editors/vim app-editors/gvim ) )
	zsh-completion? ( app-shells/zsh )"
DEPEND="${RDEPEND}
	${PYTHON_DEPS}
	app-admin/eselect-rust
	>=dev-lang/perl-5.0
	clang? ( sys-devel/clang )
	emacs? ( virtual/emacs )
	libcxx? ( sys-libs/libcxx )
	!dev-lang/rust:0"

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
	epatch "${FILESDIR}/${PN}-0.12.0-no-ldconfig.patch" "${FILESDIR}/${P}-libdir.patch"
	local commit_hash=`git rev-parse --short HEAD`
	sed -i -e "s/CFG_FILENAME_EXTRA=.*/CFG_FILENAME_EXTRA=${commit_hash}/" mk/main.mk || die
}

src_configure() {
	"${ECONF_SOURCE:-.}"/configure \
		--prefix="${EPREFIX}/usr" \
		--libdir="${EPREFIX}/usr/lib/${P}" \
		--mandir="${EPREFIX}/usr/share/${P}/man" \
		$(use_enable clang) \
		$(use_enable debug) \
		$(use_enable debug llvm-assertions) \
		$(use_enable !debug optimize) \
		$(use_enable !debug optimize-cxx) \
		$(use_enable !debug optimize-llvm) \
		$(use_enable !debug optimize-tests) \
		$(use_enable libcxx libcpp) \
		--disable-manage-submodules \
		--disable-verify-install \
		|| die
}

src_compile() {
	emake VERBOSE=1

	if use emacs; then
		cd src/etc/emacs || die
		elisp-compile *.el
		elisp-make-autoload-file "${PN}-mode-autoloads.el" .
	fi
}

src_install() {
	default

	if use emacs; then
		local sf="${T}/${SITEFILE}"
		local my_elisp_pn=${PN}-mode

		insinto "/usr/share/${P}/emacs/site-lisp/${my_elisp_pn}"
		doins -r src/etc/emacs/*.el src/etc/emacs/*.elc

		cp "${FILESDIR}/${SITEFILE}" "${sf}" || die
		sed -i -e "s:@SITELISP@:${EPREFIX}${SITELISP}/${my_elisp_pn}:g" "${sf}" || die
		insinto "/usr/share/${P}/emacs/site-lisp/site-gentoo.d/"
		doins "${sf}"
	fi

	if use vim-syntax; then
		insinto /usr/share/${P}/vim/vimfiles
		doins -r src/etc/vim/*
	fi

	if use zsh-completion; then
		insinto "/usr/share/${P}/zsh/site-functions"
		doins src/etc/zsh/_rust
	fi

	mv "${D}/usr/bin/rustc" "${D}/usr/bin/rustc-${PV}" || die
	mv "${D}/usr/bin/rustdoc" "${D}/usr/bin/rustdoc-${PV}" || die

	cat <<-EOF > "${T}"/50${P}
	LDPATH="/usr/lib/${P}"
	MANPATH="/usr/share/${P}/man"
	EOF
	doenvd "${T}"/50${P}
}

pkg_postinst() {
	eselect rust update --if-unset

	elog "Rust uses slots now, use 'eselect rust list'"
	elog "and 'eselect rust set' to list and set rust version."
	elog "For more information see 'eselect rust help'"
	elog "and http://wiki.gentoo.org/wiki/Project:Eselect/User_guide"
}

pkg_postrm() {
	eselect rust unset --if-invalid
}
