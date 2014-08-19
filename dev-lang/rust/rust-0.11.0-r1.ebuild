# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

PYTHON_COMPAT=( python{2_6,2_7} )

inherit elisp-common eutils python-any-r1

DESCRIPTION="Systems programming language from Mozilla"
HOMEPAGE="http://www.rust-lang.org/"

ARCH_SRC_URI="amd64? ( http://static.rust-lang.org/dist/${P}-x86_64-unknown-linux-gnu.tar.gz )
	x86? ( http://static.rust-lang.org/dist/${P}-i686-unknown-linux-gnu.tar.gz )"

SRC_URI="http://static.rust-lang.org/dist/${P}.tar.gz ${ARCH_SRC_URI}"

LICENSE="|| ( MIT Apache-2.0 ) BSD-1 BSD-2 BSD-4 UoI-NCSA"
SLOT="0.11"
KEYWORDS="~amd64 ~x86"

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

src_prepare() {
	epatch "${FILESDIR}/${P}-stage0.patch" "${FILESDIR}/${P}-libdir.patch"
}

src_configure() {
	use amd64 && ARCH_POSTFIX="x86_64"
	use x86 && ARCH_POSTFIX="i686"
	LOCAL_RUST_PATH="${WORKDIR}/${P}-${ARCH_POSTFIX}-unknown-linux-gnu"

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
		--enable-local-rust \
		--local-rust-root="${LOCAL_RUST_PATH}" \
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
}

pkg_postrm() {
	eselect rust unset --if-invalid
}
