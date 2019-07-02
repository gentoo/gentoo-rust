# Copyright 2017-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cargo git-r3

CARGO_FETCH_CRATES=yes

DESCRIPTION="A GTK3 GUI for managing systemd services on Linux"
HOMEPAGE="https://github.com/mmstick/systemd-manager"
RESTRICT="mirror"
LICENSE="MIT" # Update to proper Gentoo format
SLOT="0"
KEYWORDS="~amd64 arm arm64"
IUSE=""
EGIT_REPO_URI="https://github.com/mmstick/systemd-manager.git"
DEPEND=""
RDEPEND=""
