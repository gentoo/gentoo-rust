# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="6"

inherit eutils

DESCRIPTION="The Servo web browser"
HOMEPAGE="https://servo-builds.s3.amazonaws.com/index.html"

SRC_URI="https://servo-builds.s3.amazonaws.com/nightly/linux/servo-latest.tar.gz"

LICENSE="MPL-2"
SLOT="0"
KEYWORDS="-* ~amd64"
IUSE=""

DEPEND=""
RDEPEND=""

S=${WORKDIR}

pkg_pretend() {
	# Protect against people using autounmask overzealously
	use amd64 || die "binary servo only works on amd64"
}

src_install() {
	insinto /opt
	doins -r servo
	fperms 755 /opt/servo/servo
	make_wrapper servo "/opt/servo/servo" || die
}
