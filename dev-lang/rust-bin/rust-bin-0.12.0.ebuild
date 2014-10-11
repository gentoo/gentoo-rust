# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit eutils

DESCRIPTION="Systems programming language from Mozilla"
HOMEPAGE="http://www.rust-lang.org/"
SRC_URI="amd64? ( http://static.rust-lang.org/dist/rust-${PV}-x86_64-unknown-linux-gnu.tar.gz )
	x86? ( http://static.rust-lang.org/dist/rust-${PV}-i686-unknown-linux-gnu.tar.gz )"

LICENSE="|| ( MIT Apache-2.0 ) BSD-1 BSD-2 BSD-4 UoI-NCSA"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE="emacs vim-syntax zsh-completion"

DEPEND=">=app-admin/eselect-rust-0.2_pre20141011
	!dev-lang/rust:0
"
RDEPEND="${DEPEND}
	emacs? ( >=app-emacs/rust-mode-${PV} )
	vim-syntax? ( >=app-vim/rust-mode-${PV} )
	zsh-completion? ( >=app-shells/rust-zshcomp-${PV} )
"

src_unpack() {
	default

	local postfix
	use amd64 && postfix=x86_64-unknown-linux-gnu
	use x86 && postfix=i686-unknown-linux-gnu
	mv "${WORKDIR}/rust-${PV}-${postfix}" "${S}" || die
}

src_prepare() {
	epatch "${FILESDIR}/${PN}-0.12.0-no-ldconfig.patch"
}

src_install() {
	./install.sh \
		--disable-verify \
		--prefix="${D}/opt/${P}" \
		--mandir="${D}/usr/share/${P}/man"

	local rustc=rustc-bin-${PV}
	local rustdoc=rustdoc-bin-${PV}

	mv "${D}/opt/${P}/bin/rustc" "${D}/opt/${P}/bin/${rustc}" || die
	mv "${D}/opt/${P}/bin/rustdoc" "${D}/opt/${P}/bin/${rustdoc}" || die
	dosym "/opt/${P}/bin/${rustc}" "/usr/bin/${rustc}"
	dosym "/opt/${P}/bin/${rustdoc}" "/usr/bin/${rustdoc}"

	cat <<-EOF > "${T}"/50${P}
	LDPATH="/opt/${P}/lib"
	MANPATH="/usr/share/${P}/man"
	EOF
	doenvd "${T}"/50${P}

	dodir /etc/env.d/rust
	touch "${D}/etc/env.d/rust/provider-${P}" || die
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
