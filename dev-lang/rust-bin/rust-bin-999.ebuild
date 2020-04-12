# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit eutils bash-completion-r1

DESCRIPTION="Systems programming language from Mozilla"
HOMEPAGE="https://www.rust-lang.org/"
MY_SRC_URI="https://static.rust-lang.org/dist/rust-beta"
MY_STDLIB_SRC_URI="https://static.rust-lang.org/dist/rust-std-beta"

ALL_RUSTLIB_TARGETS=(
	"wasm32-unknown-unknown"
)
ALL_RUSTLIB_TARGETS=( "${ALL_RUSTLIB_TARGETS[@]/#/rustlib_targets_}" )

LICENSE="|| ( MIT Apache-2.0 ) BSD-1 BSD-2 BSD-4 UoI-NCSA"
SLOT="beta"
KEYWORDS=""
RESTRICT="network-sandbox"

IUSE="clippy cpu_flags_x86_sse2 doc libressl rls rustfmt ${ALL_RUSTLIB_TARGETS[*]}"

CDEPEND="
	>=app-eselect/eselect-rust-0.3_pre20150425
	!dev-lang/rust:0
	rustfmt? ( !dev-util/rustfmt )
"
DEPEND="${CDEPEND}
	net-misc/wget
"
RDEPEND="${CDEPEND}
	sys-libs/zlib
	!libressl? ( dev-libs/openssl:0= )
	libressl? ( dev-libs/libressl:0= )
	net-libs/libssh2
	net-misc/curl[ssl]
	!dev-util/cargo
	"
REQUIRED_USE="x86? ( cpu_flags_x86_sse2 )"

QA_PREBUILT="
	opt/${P}/bin/*-${PV}
	opt/${P}/lib/*.so
	opt/${P}/lib/rustlib/*/lib/*.so
	opt/${P}/lib/rustlib/*/lib/*.rlib*
"

src_unpack() {
	local postfix
	use amd64 && postfix=x86_64-unknown-linux-gnu
	use x86 && postfix=i686-unknown-linux-gnu
	use arm && postfix=armv7-unknown-linux-gnueabihf
	use arm64 && postfix=aarch64-unknown-linux-gnu

	wget "${MY_SRC_URI}-${postfix}.tar.xz" || die
	unpack ./"rust-beta-${postfix}.tar.xz"

	mv "${WORKDIR}/rust-beta-${postfix}" "${S}" || die

	for arch in ${ALL_RUSTLIB_TARGETS}; do
		if use ${arch}; then
			target=${arch#"rustlib_targets_"}
			elog "Adding ${target}..."
			wget "${MY_STDLIB_SRC_URI}-${target}.tar.xz" || die
			unpack ./"rust-std-beta-${target}.tar.xz"
			mv "${WORKDIR}/rust-std-beta-${target}/rust-std-${target}" "${S}/" || die
			cat "${WORKDIR}/rust-std-beta-${target}/components" >> "${S}/components"
		fi
	done
}

src_install() {
	local std=$(grep 'std' ./components | paste -s -d',')
	local components="rustc,cargo,${std}"
	use doc && components="${components},rust-docs"
	use clippy && components="${components},clippy-preview"
	if use rls; then
		local analysis=$(grep 'analysis' ./components)
		components="${components},rls-preview,${analysis}"
	fi
	use rustfmt && components="${components},rustfmt-preview"
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

	dosym "../../opt/${P}/bin/${rustc}" "/usr/bin/${rustc}"
	dosym "../../opt/${P}/bin/${rustdoc}" "/usr/bin/${rustdoc}"
	dosym "../../opt/${P}/bin/${rustgdb}" "/usr/bin/${rustgdb}"
	dosym "../../opt/${P}/bin/${rustlldb}" "/usr/bin/${rustlldb}"

	local cargo=cargo-bin-${PV}
	mv "${D}/opt/${P}/bin/cargo" "${D}/opt/${P}/bin/${cargo}" || die
	dosym "../../opt/${P}/bin/${cargo}" "/usr/bin/${cargo}"

	if use clippy; then
		local clippy_driver=clippy-driver-bin-${PV}
		local cargo_clippy=cargo-clippy-bin-${PV}
		mv "${D}/opt/${P}/bin/clippy-driver" "${D}/opt/${P}/bin/${clippy_driver}" || die
		mv "${D}/opt/${P}/bin/cargo-clippy" "${D}/opt/${P}/bin/${cargo_clippy}" || die
		dosym "../../opt/${P}/bin/${clippy_driver}" "/usr/bin/${clippy_driver}"
		dosym "../../opt/${P}/bin/${cargo_clippy}" "/usr/bin/${cargo_clippy}"
	fi
	if use rls; then
		local rls=rls-bin-${PV}
		mv "${D}/opt/${P}/bin/rls" "${D}/opt/${P}/bin/${rls}" || die
		dosym "../../opt/${P}/bin/${rls}" "/usr/bin/${rls}"
	fi
	if use rustfmt; then
		local rustfmt=rustfmt-bin-${PV}
		local cargo_fmt=cargo-fmt-bin-${PV}
		mv "${D}/opt/${P}/bin/rustfmt" "${D}/opt/${P}/bin/${rustfmt}" || die
		mv "${D}/opt/${P}/bin/cargo-fmt" "${D}/opt/${P}/bin/${cargo_fmt}" || die
		dosym "../../opt/${P}/bin/${rustfmt}" "/usr/bin/${rustfmt}"
		dosym "../../opt/${P}/bin/${cargo_fmt}" "/usr/bin/${cargo_fmt}"
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

	echo /usr/bin/cargo >> "${T}/provider-${P}"

	if use clippy; then
		echo /usr/bin/clippy-driver >> "${T}/provider-${P}"
		echo /usr/bin/cargo-clippy >> "${T}/provider-${P}"
	fi
	if use rls; then
		echo /usr/bin/rls >> "${T}/provider-${P}"
	fi
	if use rustfmt; then
		echo /usr/bin/rustfmt >> "${T}/provider-${P}"
		echo /usr/bin/cargo-fmt >> "${T}/provider-${P}"
	fi
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
		elog "install app-vim/rust-vim to get vim support for rust."
	fi

	if has_version 'app-shells/zsh'; then
		elog "install app-shells/rust-zshcomp to get zsh completion for rust."
	fi
}

pkg_postrm() {
	eselect rust unset --if-invalid
}
