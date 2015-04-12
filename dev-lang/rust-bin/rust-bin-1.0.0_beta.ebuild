# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils bash-completion-r1

MY_PV="${PV/_/-}"
DESCRIPTION="Systems programming language from Mozilla"
HOMEPAGE="http://www.rust-lang.org/"
SRC_URI="amd64? ( http://static.rust-lang.org/dist/rust-${MY_PV}-x86_64-unknown-linux-gnu.tar.gz )
	x86? ( http://static.rust-lang.org/dist/rust-${MY_PV}-i686-unknown-linux-gnu.tar.gz )"

LICENSE="|| ( MIT Apache-2.0 ) BSD-1 BSD-2 BSD-4 UoI-NCSA"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE="cargo-bundled doc"

DEPEND=">=app-eselect/eselect-rust-0.2_pre20150206
	!dev-lang/rust:0
	cargo-bundled? ( !dev-rust/cargo )
"
RDEPEND="${DEPEND}"

src_unpack() {
	default

	local postfix
	use amd64 && postfix=x86_64-unknown-linux-gnu
	use x86 && postfix=i686-unknown-linux-gnu
	mv "${WORKDIR}/rust-${MY_PV}-${postfix}" "${S}" || die
}

src_install() {
	local components=rustc
	use cargo-bundled && components="${components},cargo"
	use doc && components="${components},rust-docs"
	./install.sh \
		--components="${components}" \
		--disable-verify \
		--prefix="${D}/opt/${P}" \
		--mandir="${D}/usr/share/${P}/man" \
		--disable-ldconfig

	local rustc=rustc-bin-${PV}
	local rustdoc=rustdoc-bin-${PV}
	local rustgdb=rust-gdb-bin-${PV}

	mv "${D}/opt/${P}/bin/rustc" "${D}/opt/${P}/bin/${rustc}" || die
	mv "${D}/opt/${P}/bin/rustdoc" "${D}/opt/${P}/bin/${rustdoc}" || die
	mv "${D}/opt/${P}/bin/rust-gdb" "${D}/opt/${P}/bin/${rustgdb}" || die

	dosym "/opt/${P}/bin/${rustc}" "/usr/bin/${rustc}"
	dosym "/opt/${P}/bin/${rustdoc}" "/usr/bin/${rustdoc}"
	dosym "/opt/${P}/bin/${rustgdb}" "/usr/bin/${rustgdb}"

	cat <<-EOF > "${T}"/50${P}
	LDPATH="/opt/${P}/lib"
	MANPATH="/usr/share/${P}/man"
	EOF
	doenvd "${T}"/50${P}

	dodir /etc/env.d/rust
	touch "${D}/etc/env.d/rust/provider-${P}" || die
	if use cargo-bundled ; then
		dosym "/opt/${P}/bin/cargo" /usr/bin/cargo
		dosym "/opt/${P}/share/zsh/site-functions/_cargo" /usr/share/zsh/site-functions/_cargo
		newbashcomp "${D}/opt/${P}/etc/bash_completion.d/cargo" cargo
		rm -rf "${D}/opt/${P}/etc"
	fi
}

pkg_postinst() {
	eselect rust update --if-unset

	elog "Rust uses slots now, use 'eselect rust list'"
	elog "and 'eselect rust set' to list and set rust version."
	elog "For more information see 'eselect rust help'"
	elog "and http://wiki.gentoo.org/wiki/Project:Eselect/User_guide"

	elog "Rust installs a helper script for calling GDB now,"
	elog "for your convenience it is installed under /usr/bin/rust-gdb-bin-${PV},"

	if has_version app-editors/emacs || has_version app-editors/emacs-vcs; then
		elog "install app-emacs/rust-mode to get emacs support for rust."
	fi

	if has_version app-editors/gvim || has_version app-editors/vim; then
		elog "install app-vim/rust-mode to get vim support for rust."
	fi

	if has_version 'app-shells/zsh'; then
		elog "install app-shells/rust-zshcomp to get zsh completion for rust."
	fi
}

pkg_postrm() {
	eselect rust unset --if-invalid
}
