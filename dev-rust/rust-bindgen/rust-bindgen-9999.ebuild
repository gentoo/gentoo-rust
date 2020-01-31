# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit eutils git-r3

DESCRIPTION="A binding generator for the rust language"
HOMEPAGE="https://github.com/servo/rust-bindgen"

LICENSE="BSD"
SLOT="0"
KEYWORDS=""

IUSE=""

EGIT_REPO_URI="https://github.com/servo/rust-bindgen.git"

DEPEND=">=virtual/rust-999
	>=sys-devel/clang-3.4.2-r100:*
"
RDEPEND="${DEPEND}"

src_configure() {
	true
}

src_compile() {
	cargo build --release
}

src_install() {
	install -D -m 755 "${FILESDIR}/rust-bindgen" "${D}/usr/bin/rust-bindgen"
	install -D -m 755 target/release/bindgen "${D}/usr/bin/rust-bindgen-9999"
	install -D -t "${D}/usr/lib" target/release/libbindgen*
}
