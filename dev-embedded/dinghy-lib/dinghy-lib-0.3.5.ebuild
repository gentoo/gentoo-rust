# Copyright 2017-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# Auto-Generated by cargo-ebuild 0.1.5

EAPI=6

CRATES="
aho-corasick-0.6.4
ansi_term-0.11.0
atty-0.2.10
backtrace-0.3.8
backtrace-sys-0.1.19
base64-0.9.1
bindgen-0.37.0
bitflags-1.0.3
byteorder-1.2.3
cargo-0.27.0
cargo-dinghy-0.3.5
cc-1.0.15
cexpr-0.2.3
cfg-if-0.1.3
clang-sys-0.22.0
clap-2.31.2
cmake-0.1.31
commoncrypto-0.2.0
commoncrypto-sys-0.2.0
core-foundation-0.5.1
core-foundation-sys-0.5.1
crates-io-0.16.0
crossbeam-0.3.2
crypto-hash-0.3.1
curl-0.4.12
curl-sys-0.4.5
dinghy-build-0.3.5
dinghy-build-0.3.5
dinghy-lib-0.3.5
dinghy-lib-0.3.5
dinghy-test-0.3.5
dtoa-0.4.2
either-1.5.0
env_logger-0.5.10
error-chain-0.11.0
failure-0.1.1
failure_derive-0.1.1
filetime-0.1.15
filetime-0.2.1
flate2-1.0.1
fnv-1.0.6
foreign-types-0.3.2
foreign-types-shared-0.1.1
fs2-0.4.3
fuchsia-zircon-0.3.3
fuchsia-zircon-sys-0.3.3
git2-0.7.1
git2-curl-0.8.1
glob-0.2.11
globset-0.4.0
hex-0.3.2
home-0.3.3
humantime-1.1.1
idna-0.1.4
ignore-0.4.2
isatty-0.1.8
itertools-0.7.8
itoa-0.4.1
jobserver-0.1.11
json-0.11.13
kernel32-sys-0.2.2
lazy_static-1.0.0
lazycell-0.6.0
libc-0.2.41
libgit2-sys-0.7.1
libloading-0.5.0
libssh2-sys-0.2.7
libz-sys-1.0.18
log-0.4.1
matches-0.1.6
memchr-1.0.2
memchr-2.0.1
miniz-sys-0.1.10
miow-0.3.1
nom-3.2.1
num-traits-0.2.4
num_cpus-1.8.0
openssl-0.10.8
openssl-probe-0.1.2
openssl-sys-0.9.31
peeking_take_while-0.1.2
percent-encoding-1.0.1
pkg-config-0.3.11
plist-0.3.0
pretty_env_logger-0.2.3
proc-macro2-0.3.5
proc-macro2-0.4.3
quick-error-1.2.1
quote-0.3.15
quote-0.5.2
quote-0.6.2
rand-0.4.2
redox_syscall-0.1.38
redox_termios-0.1.1
regex-0.2.11
regex-1.0.0
regex-syntax-0.5.6
regex-syntax-0.6.0
remove_dir_all-0.5.1
rustc-demangle-0.1.8
safemem-0.2.0
same-file-1.0.2
schannel-0.1.12
scopeguard-0.3.3
semver-0.9.0
semver-parser-0.7.0
serde-1.0.59
serde_derive-1.0.59
serde_ignored-0.0.4
serde_json-1.0.17
shell-escape-0.1.4
socket2-0.3.5
strsim-0.7.0
syn-0.11.11
syn-0.14.0
synom-0.11.3
synstructure-0.6.1
tar-0.4.15
tempdir-0.3.7
tempfile-3.0.2
termcolor-0.3.6
termion-1.5.1
textwrap-0.9.0
thread_local-0.3.5
toml-0.4.6
ucd-util-0.1.1
unicode-bidi-0.3.4
unicode-normalization-0.1.7
unicode-width-0.1.5
unicode-xid-0.0.4
unicode-xid-0.1.0
unreachable-1.0.0
url-1.7.0
utf8-ranges-1.0.0
vcpkg-0.2.3
vec_map-0.8.1
void-1.0.2
walkdir-2.1.4
which-1.0.5
winapi-0.2.8
winapi-0.3.4
winapi-build-0.1.1
winapi-i686-pc-windows-gnu-0.4.0
winapi-x86_64-pc-windows-gnu-0.4.0
wincolor-0.1.6
xml-rs-0.7.0
"

inherit cargo

DESCRIPTION="Cross-compilation made easier - see main crate cargo-dinghy"
HOMEPAGE="https://medium.com/snips-ai/dinghy-painless-rust-tests-and-benches-on-ios-and-android-c9f94f81d305#.c2sx7two8"
SRC_URI="$(cargo_crate_uris ${CRATES})"
RESTRICT="mirror"
LICENSE="MIT/Apache-2.0" # Update to proper Gentoo format
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=""
RDEPEND=""
