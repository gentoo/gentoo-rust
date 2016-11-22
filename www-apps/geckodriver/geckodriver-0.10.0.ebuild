# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

CRATES="aho-corasick-0.5.2
advapi32-sys-0.1.2
bitflags-0.5.0
bzip2-0.3.0
bzip2-sys-0.1.4
clap-2.9.2
cookie-0.2.5
env_logger-0.3.4
flate2-0.2.14
gcc-0.3.31
hpack-0.2.0
httparse-1.1.2
hyper-0.9.10
idna-0.1.0
kernel32-sys-0.1.4
kernel32-sys-0.2.2
ktmw32-sys-0.1.0
language-tags-0.2.2
lazy_static-0.1.16
libc-0.2.14
log-0.3.6
matches-0.1.2
memchr-0.1.11
mime-0.2.1
miniz-sys-0.1.7
mozprofile-0.2.0
mozrunner-0.3.1
msdos_time-0.1.4
num_cpus-0.2.13
podio-0.1.5
rand-0.3.14
regex-0.1.73
regex-syntax-0.3.4
rustc-serialize-0.3.19
rustc_version-0.1.7
semver-0.1.20
solicit-0.4.4
strsim-0.4.1
tempdir-0.3.4
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
url-1.1.1
utf8-ranges-0.1.3
uuid-0.1.18
vec_map-0.6.0
webdriver-0.12.0
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
