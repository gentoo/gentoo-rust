# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

CRATES="
aho-corasick-0.6.4
bitflags-0.9.1
bitflags-1.0.1
cfg-if-0.1.2
diff-0.1.11
dtoa-0.4.2
env_logger-0.4.3
extprim-1.5.1
fuchsia-zircon-0.3.3
fuchsia-zircon-sys-0.3.3
getopts-0.2.17
itoa-0.3.4
kernel32-sys-0.2.2
lazy_static-1.0.0
libc-0.2.36
log-0.3.9
log-0.4.1
memchr-2.0.1
num-traits-0.1.42
quote-0.3.15
rand-0.4.2
regex-0.2.5
regex-syntax-0.4.2
rustc_version-0.2.1
rustfmt-${PV}
semver-0.6.0
semver-parser-0.7.0
serde-1.0.27
serde_derive-1.0.27
serde_derive_internals-0.19.0
serde_json-1.0.9
strings-0.1.1
syn-0.11.11
synom-0.11.3
syntex_errors-0.59.1
syntex_pos-0.59.1
syntex_syntax-0.59.1
term-0.4.6
thread_local-0.3.5
toml-0.4.5
unicode-segmentation-1.2.0
unicode-xid-0.0.4
unicode-xid-0.1.0
unreachable-1.0.0
utf8-ranges-1.0.0
void-1.0.2
winapi-0.2.7
winapi-0.3.4
winapi-build-0.1.1
winapi-i686-pc-windows-gnu-0.4.0
winapi-x86_64-pc-windows-gnu-0.4.0
"

inherit cargo

DESCRIPTION="Tool to find and fix Rust formatting issues"
HOMEPAGE="https://github.com/rust-lang-nursery/rustfmt"
SRC_URI="$(cargo_crate_uris ${CRATES})"
LICENSE="|| ( MIT Apache-2.0 )"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="dev-lang/rust"
RDEPEND=""
