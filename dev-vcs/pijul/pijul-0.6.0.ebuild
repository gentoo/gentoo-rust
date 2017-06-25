# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

CRATES="
advapi32-sys-0.2.0
aho-corasick-0.6.3
ansi_term-0.9.0
arrayref-0.3.4
atty-0.2.2
base64-0.5.2
bincode-0.8.0
bitflags-0.4.0
bitflags-0.8.2
byteorder-1.0.0
bytes-0.4.4
cfg-if-0.1.0
chrono-0.3.1
clap-2.24.2
cryptovec-0.3.4
deque-0.3.2
encode_unicode-0.1.3
env_logger-0.4.3
filetime-0.1.10
flate2-0.2.19
fs2-0.4.1
futures-0.1.13
gcc-0.3.49
getch-0.1.1
hex-0.2.0
httparse-1.2.2
hyper-0.10.10
hyper-rustls-0.5.0
idna-0.1.2
iovec-0.1.0
kernel32-sys-0.2.2
language-tags-0.2.2
lazy_static-0.2.8
lazycell-0.4.0
libc-0.2.23
log-0.3.8
matches-0.1.4
memchr-1.0.1
memmap-0.5.2
mime-0.2.4
miniz-sys-0.1.9
mio-0.6.8
mio-uds-0.6.4
miow-0.2.1
net2-0.2.29
nix-0.5.1
num-0.1.37
num-integer-0.1.34
num-iter-0.1.33
num-traits-0.1.37
num_cpus-1.5.0
quote-0.3.15
rand-0.3.15
rayon-0.7.0
rayon-core-1.0.0
redox_syscall-0.1.17
regex-0.2.2
regex-syntax-0.4.1
ring-0.9.7
rust-crypto-0.2.36
rustc-serialize-0.3.24
rustc_version-0.1.7
rustls-0.7.0
rustyline-1.0.0
same-file-0.1.3
sanakirja-0.8.7
scoped-tls-0.1.0
semver-0.1.20
serde-1.0.8
serde_derive-1.0.8
serde_derive_internals-0.15.1
shell-escape-0.1.3
slab-0.3.0
strsim-0.6.0
syn-0.11.11
synom-0.11.3
tar-0.4.12
tempdir-0.3.5
term-0.4.5
term_size-0.3.0
termios-0.2.2
thread-id-3.1.0
thread_local-0.3.3
thrussh-0.11.0
thrussh-keys-0.2.1
time-0.1.37
tokio-core-0.1.7
tokio-io-0.1.2
tokio-uds-0.1.4
toml-0.4.1
traitobject-0.1.0
typeable-0.1.2
unicase-1.4.0
unicode-bidi-0.3.2
unicode-normalization-0.1.4
unicode-segmentation-1.2.0
unicode-width-0.1.4
unicode-xid-0.0.4
unreachable-0.1.1
untrusted-0.5.0
url-1.4.0
user-0.1.1
utf8-ranges-1.0.0
vec_map-0.8.0
void-1.0.2
walkdir-1.0.7
webpki-0.12.1
webpki-roots-0.10.0
winapi-0.1.23
winapi-0.2.8
winapi-build-0.1.1
ws2_32-sys-0.2.1
xattr-0.1.11
"

inherit cargo

DESCRIPTION="Distributed VCS based on a sound theory of patches."
HOMEPAGE="https://pijul.org/"
SRC_URI="https://pijul.org/releases/pijul-0.6.0.tar.gz
	$(cargo_crate_uris $CRATES)"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

S="${WORKDIR}/${PN}"
