# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit eutils

DESCRIPTION="Systems programming language from Mozilla"
HOMEPAGE="http://www.rust-lang.org/"
MY_SRC_URI="http://static.rust-lang.org/dist/rust-nightly"

LICENSE="|| ( MIT Apache-2.0 ) BSD-1 BSD-2 BSD-4 UoI-NCSA"
SLOT="0"
KEYWORDS=""

IUSE="emacs vim-syntax zsh-completion"

CDEPEND=">=app-admin/eselect-rust-0.2_pre20141128
	!dev-lang/rust:0
"
DEPEND="${CDEPEND}
	net-misc/wget
"
RDEPEND="${CDEPEND}
	emacs? ( >=app-emacs/rust-mode-${PV} )
	vim-syntax? ( >=app-vim/rust-mode-${PV} )
	zsh-completion? ( >=app-shells/rust-zshcomp-${PV} )
"

src_unpack() {
	local postfix
	use amd64 && postfix=x86_64-unknown-linux-gnu
	use x86 && postfix=i686-unknown-linux-gnu

	wget "${MY_SRC_URI}-${postfix}.tar.gz" || die
	unpack ./"rust-nightly-${postfix}.tar.gz"

	mv "${WORKDIR}/rust-nightly-${postfix}" "${S}" || die
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
	local rustlldb=rust-lldb-bin-${PV}

	mv "${D}/opt/${P}/bin/rustc" "${D}/opt/${P}/bin/${rustc}" || die
	mv "${D}/opt/${P}/bin/rustdoc" "${D}/opt/${P}/bin/${rustdoc}" || die
	mv "${D}/opt/${P}/bin/rust-lldb" "${D}/opt/${P}/bin/${rustlldb}" || die

	dosym "/opt/${P}/bin/${rustc}" "/usr/bin/${rustc}"
	dosym "/opt/${P}/bin/${rustdoc}" "/usr/bin/${rustdoc}"
	dosym "/opt/${P}/bin/${rustlldb}" "/usr/bin/${rustlldb}"

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

	elog "Rust installs a helper script for calling LLDB now,"
	elog "for your convenience it is installed under /usr/bin/rust-lldb-bin-${PV},"
	elog "but note, that there is no LLDB ebuild in the tree currently,"
	elog "so you are on your own if you want to use it."
}

pkg_postrm() {
	eselect rust unset --if-invalid
}
