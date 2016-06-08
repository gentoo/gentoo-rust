# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

PYTHON_COMPAT=( python2_7 )

inherit eutils git-r3 multilib python-any-r1

DESCRIPTION="Systems programming language from Mozilla"
HOMEPAGE="http://www.rust-lang.org/"
EGIT_REPO_URI="https://github.com/rust-lang/rust.git"

LICENSE="|| ( MIT Apache-2.0 ) BSD-1 BSD-2 BSD-4 UoI-NCSA"
SLOT="git"
KEYWORDS=""

IUSE="clang debug doc libcxx"
REQUIRED_USE="libcxx? ( clang )"

CDEPEND="libcxx? ( sys-libs/libcxx )
	>=app-eselect/eselect-rust-0.3_pre20150425
	!dev-lang/rust:0
"
DEPEND="${CDEPEND}
	${PYTHON_DEPS}
	>=dev-lang/perl-5.0
	clang? ( sys-devel/clang )
"
RDEPEND="${CDEPEND}
"

src_unpack() {
	git-r3_src_unpack

	use amd64 && BUILD_TRIPLE=x86_64-unknown-linux-gnu
	use x86 && BUILD_TRIPLE=i686-unknown-linux-gnu
	export CFG_SRC_DIR="${S}" && \
		cd ${S} && \
		mkdir -p "${S}/dl" && \
		mkdir -p "${S}/${BUILD_TRIPLE}/stage0/bin" && \
		python2 "${S}/src/etc/get-stage0.py" ${BUILD_TRIPLE} || die
}

src_prepare() {
	local postfix="gentoo-${SLOT}"
	sed -i -e "s/CFG_FILENAME_EXTRA=.*/CFG_FILENAME_EXTRA=${postfix}/" mk/main.mk || die
	find mk -name '*.mk' -exec \
		 sed -i -e "s/-Werror / /g" {} \; || die
}

src_configure() {
	export CFG_DISABLE_LDCONFIG="notempty"
	"${ECONF_SOURCE:-.}"/configure \
		--prefix="${EPREFIX}/usr" \
		--libdir="${EPREFIX}/usr/$(get_libdir)/${P}" \
		--mandir="${EPREFIX}/usr/share/${P}/man" \
		--disable-manage-submodules \
		$(use_enable clang) \
		$(use_enable debug) \
		$(use_enable debug llvm-assertions) \
		$(use_enable !debug optimize) \
		$(use_enable !debug optimize-cxx) \
		$(use_enable !debug optimize-llvm) \
		$(use_enable !debug optimize-tests) \
		$(use_enable doc docs) \
		$(use_enable libcxx libcpp) \
		|| die
}

src_compile() {
	emake VERBOSE=1
}

src_install() {
	default

	mv "${D}/usr/bin/rustc" "${D}/usr/bin/rustc-${PV}" || die
	mv "${D}/usr/bin/rustdoc" "${D}/usr/bin/rustdoc-${PV}" || die
	mv "${D}/usr/bin/rust-gdb" "${D}/usr/bin/rust-gdb-${PV}" || die

	dodir "/usr/share/doc/rust-${PV}/"
	mv "${D}/usr/share/doc/rust"/* "${D}/usr/share/doc/rust-${PV}/" || die
	rmdir "${D}/usr/share/doc/rust/" || die

	cat <<-EOF > "${T}"/50${P}
	LDPATH="/usr/$(get_libdir)/${P}"
	MANPATH="/usr/share/${P}/man"
	EOF
	doenvd "${T}"/50${P}

	cat <<-EOF > "${T}/provider-${P}"
	/usr/bin/rustdoc
	/usr/bin/rust-gdb
	EOF
	dodir /etc/env.d/rust
	insinto /etc/env.d/rust
	doins "${T}/provider-${P}"
}

pkg_postinst() {
	eselect rust update --if-unset

	elog "Rust installs a helper script for calling GDB now,"
	elog "for your convenience it is installed under /usr/bin/rust-gdb-${PV}."

	if has_version app-editors/emacs || has_version app-editors/emacs-vcs; then
		elog "install app-emacs/rust-mode to get emacs support for rust."
	fi

	if has_version app-editors/gvim || has_version app-editors/vim; then
		elog "install app-vim/rust-mode to get vim support for rust."
	fi

	if has_version 'app-shells/zsh'; then
		elog "install app-shells/rust-zshcomp to get zsh completion for rust."
	fi
}

pkg_postrm() {
	eselect rust unset --if-invalid
}
