# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
inherit versionator

DESCRIPTION="Virtual for Rust language compiler"
HOMEPAGE=""
SRC_URI=""

LICENSE=""
SLOT="0/$(get_version_component_range 1-2 ${PV})"
KEYWORDS="~amd64 ~x86"

DEPEND=""
RDEPEND="
|| (
	=dev-lang/rust-${PV}*:${SLOT}
	=dev-lang/rust-bin-${PV}*:${SLOT}
)"