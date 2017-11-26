# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils bash-completion-r1

DESCRIPTION="Systems programming language from Mozilla"
HOMEPAGE="http://www.rust-lang.org/"
MY_SRC_URI="https://static.rust-lang.org/dist/rust-nightly"

LICENSE="|| ( MIT Apache-2.0 ) BSD-1 BSD-2 BSD-4 UoI-NCSA"
SLOT="nightly"
KEYWORDS=""

IUSE="doc tools"

CDEPEND=">=app-eselect/eselect-rust-0.3_pre20150425
	!dev-lang/rust:0
"
DEPEND="${CDEPEND}
	net-misc/wget
"
RDEPEND="${CDEPEND}
"

QA_PREBUILT="
	opt/${P}/bin/rustc-bin-${PV}
	opt/${P}/bin/rustdoc-bin-${PV}
	opt/${P}/lib/*.so
	opt/${P}/lib/rustlib/*/lib/*.so
"

src_unpack() {
	local postfix
	use amd64 && postfix=x86_64-unknown-linux-gnu
	use x86 && postfix=i686-unknown-linux-gnu

	wget "${MY_SRC_URI}-${postfix}.tar.gz" || die
	unpack ./"rust-nightly-${postfix}.tar.gz"

	mv "${WORKDIR}/rust-nightly-${postfix}" "${S}" || die
}

src_install() {
	local std=$(grep 'std' ./components)
	local components="rustc,${std}"
	if use tools; then
		local analysis=$(grep 'analysis' ./components)
		components="${components},rls-preview,${analysis}"
	fi
	use doc && components="${components},rust-docs"
	./install.sh \
		--components="${components}" \
		--disable-verify \
		--prefix="${D}/opt/${P}" \
		--mandir="${D}/usr/share/${P}/man" \
		--disable-ldconfig \
		|| die

	local rustc=rustc-bin-${PV}
	local rustdoc=rustdoc-bin-${PV}
	local rustgdb=rust-gdb-bin-${PV}
	local rustlldb=rust-lldb-bin-${PV}

	mv "${D}/opt/${P}/bin/rustc" "${D}/opt/${P}/bin/${rustc}" || die
	mv "${D}/opt/${P}/bin/rustdoc" "${D}/opt/${P}/bin/${rustdoc}" || die
	mv "${D}/opt/${P}/bin/rust-gdb" "${D}/opt/${P}/bin/${rustgdb}" || die
	mv "${D}/opt/${P}/bin/rust-lldb" "${D}/opt/${P}/bin/${rustlldb}" || die

	dosym "/opt/${P}/bin/${rustc}" "/usr/bin/${rustc}"
	dosym "/opt/${P}/bin/${rustdoc}" "/usr/bin/${rustdoc}"
	dosym "/opt/${P}/bin/${rustgdb}" "/usr/bin/${rustgdb}"
	dosym "/opt/${P}/bin/${rustlldb}" "/usr/bin/${rustlldb}"

	if use tools; then
		local rls=rls-bin-${PV}
		mv "${D}/opt/${P}/bin/rls" "${D}/opt/${P}/bin/${rls}" || die
		dosym "/opt/${P}/bin/${rls}" "/usr/bin/${rls}"
	fi

	cat <<-EOF > "${T}"/50${P}
	LDPATH="/opt/${P}/lib"
	MANPATH="/usr/share/${P}/man"
	EOF
	doenvd "${T}"/50${P}

	cat <<-EOF > "${T}/provider-${P}"
	/usr/bin/rustdoc
	/usr/bin/rust-gdb
	/usr/bin/rust-lldb
	EOF

	use tools && cat <<-EOF >> "${T}/provider-${P}"
	/usr/bin/rls
	EOF

	dodir /etc/env.d/rust
	insinto /etc/env.d/rust
	doins "${T}/provider-${P}"
}

pkg_postinst() {
	eselect rust update --if-unset

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
