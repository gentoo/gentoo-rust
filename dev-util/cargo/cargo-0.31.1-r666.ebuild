# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

CARGO_SNAPSHOT_DATE="2016-09-01"

inherit cargo bash-completion-r1 multiprocessing versionator rust-toolchain

CARGO_FETCH_CRATES=yes

BOOTSTRAP_VERSION="0.$(($(get_version_component_range 2) - 1)).0"

DESCRIPTION="The Rust's package manager"
HOMEPAGE="http://crates.io"
SRC_URI="https://github.com/rust-lang/cargo/archive/${PV}.tar.gz -> ${P}.tar.gz
	$(rust_all_arch_uris cargo-${BOOTSTRAP_VERSION})"

RESTRICT="mirror"
LICENSE="|| ( MIT Apache-2.0 )"
SLOT="0"
KEYWORDS="amd64 ~arm64 x86"

IUSE="doc libressl"

COMMON_DEPEND="sys-libs/zlib
	!libressl? ( dev-libs/openssl:0= )
	libressl? ( dev-libs/libressl:0= )
	net-libs/libssh2
	net-libs/http-parser:="
RDEPEND="${COMMON_DEPEND}
	!dev-util/cargo-bin
	net-misc/curl[ssl]"
DEPEND="${COMMON_DEPEND}
	>=virtual/rust-1.30.1
	dev-util/cmake
	sys-apps/coreutils
	sys-apps/diffutils
	sys-apps/findutils
	sys-apps/sed"

src_compile() {
	export CARGO_HOME="${ECARGO_HOME}"
	local cargo="${WORKDIR}/cargo-${BOOTSTRAP_VERSION}-$(rust_abi)/cargo/bin/cargo"
	${cargo} build -j$(makeopts_jobs) --release || die

	# Building HTML documentation
	use doc && ${cargo} doc
}

src_install() {
	dobin target/release/cargo

	# Install HTML documentation
	use doc && HTML_DOCS=("target/doc")
	einstalldocs

	newbashcomp src/etc/cargo.bashcomp.sh cargo
	insinto /usr/share/zsh/site-functions
	doins src/etc/_cargo
	doman src/etc/man/*
}
