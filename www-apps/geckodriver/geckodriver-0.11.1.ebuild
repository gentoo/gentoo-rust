# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

CRATES="advapi32-sys-0.1.2
aho-corasick-0.5.2
ansi_term-0.7.5
bitflags-0.7.0
bzip2-0.3.0
bzip2-sys-0.1.4
chrono-0.2.25
clap-2.10.0
cookie-0.2.5
crossbeam-0.2.10
flate2-0.2.14
gcc-0.3.32
hpack-0.2.0
httparse-1.1.2
hyper-0.9.10
idna-0.1.0
isatty-0.1.1
kernel32-sys-0.1.4
kernel32-sys-0.2.2
ktmw32-sys-0.1.0
language-tags-0.2.2
lazy_static-0.1.16
lazy_static-0.2.1
libc-0.2.15
log-0.3.6
matches-0.1.2
memchr-0.1.11
mime-0.2.2
miniz-sys-0.1.7
mozprofile-0.2.0
mozrunner-0.3.1
msdos_time-0.1.4
num-0.1.35
num-integer-0.1.32
num-iter-0.1.32
num-traits-0.1.35
num_cpus-0.2.13
podio-0.1.5
rand-0.3.14
regex-0.1.73
regex-syntax-0.3.4
rustc-serialize-0.3.19
rustc_version-0.1.7
semver-0.1.20
slog-1.0.0
slog-atomic-0.4.0
slog-stdlog-1.0.0
slog-stream-1.0.0
slog-term-1.0.0
solicit-0.4.4
strsim-0.4.1
tempdir-0.3.5
term_size-0.1.0
thread-id-2.0.0
thread_local-0.2.6
time-0.1.35
traitobject-0.0.1
typeable-0.1.2
unicase-1.4.0
unicode-bidi-0.2.3
unicode-normalization-0.1.2
unicode-width-0.1.3
url-1.2.0
utf8-ranges-0.1.3
uuid-0.1.18
vec_map-0.6.0
webdriver-0.15.0
winapi-0.2.8
winapi-build-0.1.1
winreg-0.3.5
zip-0.1.17"

inherit cargo

DESCRIPTION="Proxy for using W3C WebDriver clients to interact with Gecko-based browsers"
HOMEPAGE="https://github.com/mozilla/geckodriver"
SRC_URI="https://github.com/mozilla/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
	$(cargo_crate_uris $CRATES)"

LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS="-*"

DEPEND=""
RDEPEND="${DEPEND}"
