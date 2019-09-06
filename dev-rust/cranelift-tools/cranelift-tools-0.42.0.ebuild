# Copyright 2017-2019 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# Auto-Generated by cargo-ebuild 0.1.5

EAPI=7

CRATES="
aho-corasick-0.7.6
ansi_term-0.11.0
arrayref-0.3.5
arrayvec-0.4.11
atty-0.2.13
autocfg-0.1.6
backtrace-0.3.37
backtrace-sys-0.1.31
base64-0.10.1
bitflags-1.1.0
blake2b_simd-0.5.8
byteorder-1.3.2
capstone-0.6.0
capstone-sys-0.10.0
cc-1.0.42
cfg-if-0.1.9
chrono-0.4.9
clap-2.33.0
clicolors-control-1.0.1
cloudabi-0.0.3
cmake-0.1.42
console-0.8.0
constant_time_eq-0.1.4
cranelift-0.42.0
cranelift-bforest-0.42.0
cranelift-codegen-0.42.0
cranelift-codegen-meta-0.42.0
cranelift-entity-0.42.0
cranelift-faerie-0.42.0
cranelift-frontend-0.42.0
cranelift-module-0.42.0
cranelift-native-0.42.0
cranelift-preopt-0.42.0
cranelift-reader-0.42.0
cranelift-simplejit-0.42.0
cranelift-wasm-0.42.0
crossbeam-utils-0.6.6
dirs-2.0.2
dirs-sys-0.3.4
encode_unicode-0.3.6
env_logger-0.6.2
errno-0.2.4
errno-dragonfly-0.1.1
faerie-0.11.0
failure-0.1.5
failure_derive-0.1.5
file-per-thread-logger-0.1.2
filecheck-0.4.0
fuchsia-cprng-0.1.1
gcc-0.3.55
glob-0.2.11
goblin-0.0.24
hashbrown-0.5.0
hashmap_core-0.1.11
humantime-1.2.0
indexmap-1.1.0
indicatif-0.11.0
itoa-0.4.4
lazy_static-1.4.0
libc-0.2.62
lock_api-0.3.1
log-0.4.8
mach-0.2.3
memchr-2.2.1
memmap-0.7.0
nodrop-0.1.13
num-integer-0.1.41
num-traits-0.2.8
num_cpus-1.10.1
number_prefix-0.2.8
parking_lot-0.9.0
parking_lot_core-0.6.2
plain-0.2.3
pretty_env_logger-0.3.1
proc-macro2-0.4.30
proc-macro2-1.0.2
quick-error-1.2.2
quote-0.6.13
quote-1.0.2
rand_core-0.3.1
rand_core-0.4.2
rand_os-0.1.3
raw-cpuid-6.1.0
rdrand-0.4.0
redox_syscall-0.1.56
redox_users-0.3.1
regex-1.3.1
regex-syntax-0.6.12
region-2.1.2
rust-argon2-0.5.1
rustc-demangle-0.1.16
rustc_version-0.2.3
ryu-1.0.0
same-file-1.0.5
scopeguard-1.0.0
scroll-0.9.2
scroll_derive-0.9.5
semver-0.9.0
semver-parser-0.7.0
serde-1.0.99
serde_derive-1.0.99
serde_json-1.0.40
smallvec-0.6.10
string-interner-0.7.1
strsim-0.8.0
syn-0.15.44
syn-1.0.5
synstructure-0.10.2
target-lexicon-0.8.1
term-0.6.1
termcolor-1.0.5
termios-0.3.1
textwrap-0.11.0
thread_local-0.3.6
time-0.1.42
unicode-width-0.1.6
unicode-xid-0.1.0
unicode-xid-0.2.0
vec_map-0.8.1
wabt-0.9.1
wabt-sys-0.6.1
walkdir-2.2.9
wasmparser-0.37.1
winapi-0.3.8
winapi-i686-pc-windows-gnu-0.4.0
winapi-util-0.1.2
winapi-x86_64-pc-windows-gnu-0.4.0
wincolor-1.0.2
"

inherit cargo

DESCRIPTION="Binaries for testing the Cranelift libraries"
HOMEPAGE="https://github.com/CraneStation/cranelift"

SRCHASH=117178cd8d12229c680c55e2b2a483a28ced84a2

SRC_URI="https://github.com/CraneStation/cranelift/archive/${SRCHASH}.tar.gz -> ${P}.tar.gz
	$(cargo_crate_uris ${CRATES})"
RESTRICT="mirror"
LICENSE="Apache-2.0-with-LLVM-exceptions"
SLOT="0"
KEYWORDS="~amd64"
IUSE="cpu_flags_x86_sse2 test"

DEPEND=">=virtual/rust-1.35.0"
RDEPEND=""
REQUIRED_USE="x86? ( cpu_flags_x86_sse2 )"

S="${WORKDIR}"/cranelift-${SRCHASH}

src_configure() {
	# Do nothing
	echo "Configuring cranelift..."
}

src_compile() {
	export CARGO_HOME="${ECARGO_HOME}"
	cargo build -j$(makeopts_jobs) --release || die
}

src_test() {
	export RUST_BACKTRACE=1
	cargo test --all -j$(makeopts_jobs) || die "tests failed"
}

src_install() {
	dobin target/release/clif-util
}
