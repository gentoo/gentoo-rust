# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cargo bash-completion-r1

CRATES="
advapi32-sys-0.2.0
aho-corasick-0.5.3
aho-corasick-0.6.3
bitflags-0.7.0
bufstream-0.1.2
cfg-if-0.1.0
chrono-0.2.25
cmake-0.1.22
crossbeam-0.2.10
curl-0.4.6
curl-sys-0.3.11
docopt-0.7.0
dtoa-0.4.1
env_logger-0.4.2
filetime-0.1.10
flate2-0.2.17
foreign-types-0.2.0
fs2-0.4.1
gcc-0.3.45
gdi32-sys-0.2.0
git2-0.6.4
git2-curl-0.7.0
glob-0.2.11
hamcrest-0.1.1
idna-0.1.0
itoa-0.3.1
kernel32-sys-0.2.2
lazy_static-0.2.5
libc-0.2.21
libgit2-sys-0.6.8
libssh2-sys-0.2.5
libz-sys-1.0.13
log-0.3.7
matches-0.1.4
memchr-0.1.11
memchr-1.0.1
miniz-sys-0.1.9
miow-0.2.1
net2-0.2.27
num-0.1.37
num-bigint-0.1.37
num-complex-0.1.36
num_cpus-1.3.0
num-integer-0.1.33
num-iter-0.1.33
num-rational-0.1.36
num-traits-0.1.37
openssl-0.9.10
openssl-probe-0.1.0
openssl-sys-0.9.10
pkg-config-0.3.9
psapi-sys-0.1.0
quote-0.3.15
rand-0.3.15
redox_syscall-0.1.17
regex-0.1.80
regex-0.2.1
regex-syntax-0.3.9
regex-syntax-0.4.0
rustc-serialize-0.3.23
semver-0.6.0
semver-parser-0.7.0
serde-0.9.12
serde_codegen_internals-0.14.2
serde_derive-0.9.12
serde_ignored-0.0.2
serde_json-0.9.9
shell-escape-0.1.3
strsim-0.6.0
syn-0.11.9
synom-0.11.3
tar-0.4.11
tempdir-0.3.5
term-0.4.5
thread-id-2.0.0
thread-id-3.0.0
thread_local-0.2.7
thread_local-0.3.3
time-0.1.36
toml-0.3.1
unicode-bidi-0.2.5
unicode-normalization-0.1.4
unicode-xid-0.0.4
unreachable-0.1.1
url-1.4.0
user32-sys-0.2.0
utf8-ranges-0.1.3
utf8-ranges-1.0.0
void-1.0.2
winapi-0.2.8
winapi-build-0.1.1
ws2_32-sys-0.2.1
"

CHOST_amd64=x86_64-unknown-linux-gnu
CHOST_x86=i686-unknown-linux-gnu

CARGO_STAGE0_VERSION="${PV}"
CARGO_STAGE0_amd64="cargo-${CARGO_STAGE0_VERSION}-${CHOST_amd64}"
CARGO_STAGE0_x86="cargo-${CARGO_STAGE0_VERSION}-${CHOST_x86}"

DESCRIPTION="The Rust's package manager"
HOMEPAGE="http://crates.io"
SRC_URI="https://github.com/rust-lang/cargo/archive/${PV}.tar.gz -> ${P}.tar.gz
	$(cargo_crate_uris ${CRATES})
	amd64? ( https://static.rust-lang.org/dist/${CARGO_STAGE0_amd64}.tar.gz )
	x86? ( https://static.rust-lang.org/dist/${CARGO_STAGE0_x86}.tar.gz )
"

RESTRICT="mirror"
LICENSE="|| ( MIT Apache-2.0 )"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE="doc libressl"

COMMON_DEPEND="sys-libs/zlib
	!libressl? ( dev-libs/openssl:0= )
	libressl? ( dev-libs/libressl:0= )
	net-libs/libssh2
	net-libs/http-parser"
RDEPEND="${COMMON_DEPEND}
	!dev-util/cargo-bin
	net-misc/curl[ssl]"
DEPEND="${COMMON_DEPEND}
	>=virtual/rust-1.9.0
	dev-util/cmake
	sys-apps/coreutils
	sys-apps/diffutils
	sys-apps/findutils
	sys-apps/sed"

src_configure() {
	local cargo_stagename="CARGO_STAGE0_${ARCH}"
	local cargo_stage0="${!cargo_stagename}"

	# Cargo only supports these GNU triples:
	# - Linux: <arch>-unknown-linux-gnu
	# - MacOS: <arch>-apple-darwin
	# - Windows: <arch>-pc-windows-gnu
	# where <arch> could be 'x86_64' (amd64) or 'i686' (x86)
	use amd64 && CTARGET="x86_64-unknown-linux-gnu"
	use x86 && CTARGET="i686-unknown-linux-gnu"

	# NOTE: 'disable-nightly' is used by crates (such as 'matches') to entirely
	# skip their internal libraries that make use of unstable rustc features.
	# Don't use 'enable-nightly' with a stable release of rustc as DEPEND,
	# otherwise you could get compilation issues.
	# see: github.com/gentoo/gentoo-rust/issues/13
	local myeconfargs=(
		--host=${CTARGET}
		--build=${CTARGET}
		--target=${CTARGET}
		--cargo="${WORKDIR}/${cargo_stage0}/cargo/bin/cargo"
		--enable-optimize
		--release-channel=stable
		--disable-verify-install
		--disable-debug
		--disable-cross-tests
	)
	econf "${myeconfargs[@]}"
}

src_compile() {
	# Building sources
	export CARGO_HOME="${ECARGO_HOME}"
	emake VERBOSE=1 PKG_CONFIG_PATH=""

	# Building HTML documentation
	use doc && emake doc
}

src_install() {
	emake prepare-image-${CTARGET} IMGDIR_${CTARGET}="${ED}/usr"

	# Install HTML documentation
	use doc && HTML_DOCS=("target/doc")
	einstalldocs

	dobashcomp "${ED}"/usr/etc/bash_completion.d/cargo
	rm -rf "${ED}"/usr/etc || die
}

src_test() {
	# Running unit tests
	# NOTE: by default 'make test' uses the copy of cargo (v0.0.1-pre-nighyly)
	# from the installer snapshot instead of the version just built, so the
	# ebuild needs to override the value of CFG_LOCAL_CARGO to avoid false
	# positives from unit tests.
	emake test \
		CFG_ENABLE_OPTIMIZE=1 \
		VERBOSE=1 \
		CFG_LOCAL_CARGO="${WORKDIR}"/${P}/target/${CTARGET}/release/cargo
}
