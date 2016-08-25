# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

case ${EAPI} in
    5) : ;;
    6) : ;;
    *) die "EAPI=${EAPI:-0} is not supported" ;;
esac

DEPEND="=dev-util/cargo-9999"

EXPORT_FUNCTIONS src_unpack src_prepare src_compile src_install

CARGO_HOME="${WORKDIR}/cargo_home"

# @FUNCTION: cargo_crate_uris
# @DESCRIPTION:
# Generates the URIs to put in SRC_URI to help fetch dependencies.
cargo_crate_uris() {
    for crate in $*; do
        local name version url
        name="${crate%-*}"
        version="${crate##*-}"
        url="https://crates.io/api/v1/crates/${name}/${version}/download -> ${crate}.crate"
        echo $url
    done
}

cargo_src_unpack() {
    mkdir -p "${CARGO_HOME}" || die

    local archive
    for archive in ${A}; do
        case "${archive}" in
            *.crate)
                ebegin "Unpacking ${archive}"
                tar -xf "${DISTDIR}"/${archive} -C "${CARGO_HOME}" || die
                echo "{\"package\": \"$(sha256sum ${DISTDIR}/${archive} | cut -f1 -d' ')\",\"files\":{}}" > "${CARGO_HOME}"/$(basename ${archive} .crate)/.cargo-checksum.json
                eend $?
                ;;
            *)
                unpack ${archive}
                ;;
        esac
    done
}

cargo_src_prepare() {
    mkdir .cargo
    cat > .cargo/config <<EOL
[source.crates-io]
registry = 'https://github.com/rust-lang/crates.io-index'
replace-with = 'ebuild-registry'

[source.ebuild-registry]
directory = '${CARGO_HOME}'
EOL
}

cargo_src_compile() {
    ebegin "Running cargo build"
    cargo build --release --verbose || die
}

cargo_src_install() {
    ebegin "Running cargo install"
    cargo install --root="${D}/usr" || die
    rm ${D}/usr/.crates.toml
}
