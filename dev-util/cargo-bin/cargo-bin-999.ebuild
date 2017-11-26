# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit bash-completion-r1

DESCRIPTION="The Rust's package manager"
HOMEPAGE="http://crates.io"
MY_SRC_URI="https://static.rust-lang.org/dist/rust-nightly"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="0"
KEYWORDS=""

IUSE="libressl"

RDEPEND="!dev-util/cargo
	!libressl? ( dev-libs/openssl:* )
	libressl? ( dev-libs/libressl:0 )
	net-misc/curl[ssl]
	net-libs/libssh2
	net-libs/http-parser
	sys-libs/zlib"

src_unpack() {
	local postfix
	use amd64 && postfix=x86_64-unknown-linux-gnu
	use x86 && postfix=i686-unknown-linux-gnu

	wget "${MY_SRC_URI}-${postfix}.tar.gz" || die
	unpack ./"rust-nightly-${postfix}.tar.gz"

	mv "${WORKDIR}/rust-nightly-${postfix}" "${S}" || die
}

src_install() {
	local components=cargo
	./install.sh \
		--components="${components}" \
		--disable-verify \
		--prefix="${D}/opt/${P}" \
		--mandir="${D}/usr/share/${P}/man" \
		--disable-ldconfig \
		|| die

	dosym "/opt/${P}/bin/cargo" /usr/bin/cargo
	dosym "/opt/${P}/share/zsh/site-functions/_cargo" /usr/share/zsh/site-functions/_cargo
	newbashcomp "${D}/opt/${P}/etc/bash_completion.d/cargo" cargo
	rm -rf "${D}/opt/${P}/etc" || die
}
