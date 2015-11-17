# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
AUTOTOOLS_IN_SOURCE_BUILD=1
inherit bash-completion-r1 autotools-utils

DESCRIPTION="The Rust's package manager"
HOMEPAGE="http://crates.io"

CARGO_SNAPSHOT_DATE="2015-04-02"
RUST_INSTALLER_COMMIT="c37d3747da75c280237dc2d6b925078e69555499"

crate_uris(){
	while (( "$#" )); do
		local name version url
		name="${1%-*}"
		version="${1##*-}"
		url="https://crates.io/api/v1/crates/${name}/${version}/download -> ${1}.crate"
		echo $url
		shift
	done
}

CRATES="aho-corasick-0.3.4
bitflags-0.1.1
bufstream-0.1.1
cmake-0.1.7
crossbeam-0.1.5
curl-0.2.12
curl-sys-0.1.26
docopt-0.6.74
env_logger-0.3.1
filetime-0.1.6
flate2-0.2.9
gcc-0.3.19
git2-0.3.2
git2-curl-0.3.0
glob-0.2.10
hamcrest-0.1.0
libc-0.1.10
libgit2-sys-0.3.6
libssh2-sys-0.1.31
libz-sys-0.1.9
log-0.3.2
matches-0.1.2
memchr-0.1.6
miniz-sys-0.1.6
num-0.1.27
num_cpus-0.2.6
openssl-sys-0.6.7
pkg-config-0.3.6
rand-0.3.11
regex-0.1.41
regex-syntax-0.2.2
rustc-serialize-0.3.16
semver-0.1.20
strsim-0.3.0
tar-0.3.1
tempdir-0.3.4
term-0.2.12
time-0.1.32
toml-0.1.23
url-0.2.37
"

SRC_URI="https://github.com/rust-lang/cargo/archive/${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/rust-lang/rust-installer/archive/${RUST_INSTALLER_COMMIT}.tar.gz -> rust-installer-${RUST_INSTALLER_COMMIT}.tar.gz
	$(crate_uris $CRATES)
	x86?   (
		https://static-rust-lang-org.s3.amazonaws.com/cargo-dist/${CARGO_SNAPSHOT_DATE}/cargo-nightly-i686-unknown-linux-gnu.tar.gz ->
		cargo-nightly-i686-unknown-linux-gnu-${CARGO_SNAPSHOT_DATE}.tar.gz
	)
	amd64? (
		https://static-rust-lang-org.s3.amazonaws.com/cargo-dist/${CARGO_SNAPSHOT_DATE}/cargo-nightly-x86_64-unknown-linux-gnu.tar.gz ->
		cargo-nightly-x86_64-unknown-linux-gnu-${CARGO_SNAPSHOT_DATE}.tar.gz
	)"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE="doc test"

COMMON_DEPEND="sys-libs/zlib
	dev-libs/openssl:*
	net-libs/libssh2
	net-libs/http-parser"
RDEPEND="${COMMON_DEPEND}
	!dev-util/cargo-bin
	net-misc/curl[ssl]"
DEPEND="${COMMON_DEPEND}
	>=virtual/rust-1.1.0
	dev-util/cmake"

PATCHES=(
	"${FILESDIR}"/${P}-local-deps.patch
	"${FILESDIR}"/${P}-test.patch
)

src_unpack() {
	for archive in ${A}; do
		case "${archive}" in
			*.crate)
				ebegin "Unpacking ${archive}"
				tar -xf "${DISTDIR}"/${archive} || die
				eend $?
				;;
			*)
				unpack ${archive}
				;;
		esac
	done

	mv cargo-nightly-*-unknown-linux-gnu "cargo-snapshot" || die
	mv "rust-installer-${RUST_INSTALLER_COMMIT}"/* "${P}"/src/rust-installer || die
}

src_prepare() {
	pushd "${WORKDIR}" &>/dev/null
	autotools-utils_src_prepare
	popd &>/dev/null

	# FIX: doc path
	sed -i \
		-e "s:/share/doc/cargo:/share/doc/${PF}:" \
		Makefile.in || die
}

src_configure() {
	# Defines the level of verbosity.
	ECARGO_VERBOSE=""
	[[ -z ${PORTAGE_VERBOSE} ]] || ECARGO_VERBOSE=1

	# Cargo only supports these GNU triples:
	# - Linux: <arch>-unknown-linux-gnu
	# - MacOS: <arch>-apple-darwin
	# - Windows: <arch>-pc-windows-gnu
	# where <arch> could be 'x86_64' (amd64) or 'i686' (x86)
	CTARGET="-unknown-linux-gnu"
	use amd64 && CTARGET="x86_64${CTARGET}"
	use x86 && CTARGET="i686${CTARGET}"

	# NOTE: 'disable-nightly' is used by crates (such as 'matches') to entirely
	# skip their internal libraries that make use of unstable rustc features.
	# Don't use 'enable-nightly' with a stable release of rustc as DEPEND,
	# otherwise you could get compilation issues.
	# see: github.com/gentoo/gentoo-rust/issues/13
	local myeconfargs=(
		--build=${CTARGET}
		--host=${CTARGET}
		--target=${CTARGET}
		--enable-optimize
		--disable-nightly
		--disable-verify-install
		--disable-debug
		--disable-cross-tests
		--local-cargo="${WORKDIR}"/cargo-snapshot/cargo/bin/cargo
	)
	autotools-utils_src_configure
}

src_compile() {
	# Building sources
	autotools-utils_src_compile VERBOSE=${ECARGO_VERBOSE} PKG_CONFIG_PATH=""

	# Building HTML documentation
	use doc && emake doc
}

src_install() {
	autotools-utils_src_install VERBOSE=${ECARGO_VERBOSE} CFG_DISABLE_LDCONFIG="true"

	# Install HTML documentation
	use doc && dohtml -r target/doc/*

	dobashcomp "${ED}"/usr/etc/bash_completion.d/cargo
	rm -r "${ED}"/usr/etc || die
}

src_test() {
	if has sandbox $FEATURES && has network-sandbox $FEATURES; then
		eerror "Some tests require sandbox, and network-sandbox to be disabled in FEATURES."
	fi

	# Running unit tests
	# NOTE: by default 'make test' uses the copy of cargo (v0.0.1-pre-nighyly)
	# from the installer snapshot instead of the version just built, so the
	# ebuild needs to override the value of CFG_LOCAL_CARGO to avoid false
	# positives from unit tests.
	autotools-utils_src_test \
		CFG_ENABLE_OPTIMIZE=1 \
		VERBOSE=${ECARGO_VERBOSE} \
		CFG_LOCAL_CARGO="${WORKDIR}"/${P}/target/${CTARGET}/release/cargo
}
