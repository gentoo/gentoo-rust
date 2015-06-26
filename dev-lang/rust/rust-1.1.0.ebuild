# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

PYTHON_COMPAT=( python2_7 )

inherit eutils python-any-r1

MY_P="rustc-${PV}"

DESCRIPTION="Systems programming language from Mozilla"
HOMEPAGE="http://www.rust-lang.org/"

SRC_URI="http://static.rust-lang.org/dist/${MY_P}-src.tar.gz
	x86?   ( http://static.rust-lang.org/stage0-snapshots/rust-stage0-2015-04-27-857ef6e-linux-i386-0bc8cffdce611fb71fd7d3d8e7cdbfaf748a4f16.tar.bz2 )
	amd64? ( http://static.rust-lang.org/stage0-snapshots/rust-stage0-2015-04-27-857ef6e-linux-x86_64-94089740e48167c5975c92c139ae9c286764012f.tar.bz2 )"

LICENSE="|| ( MIT Apache-2.0 ) BSD-1 BSD-2 BSD-4 UoI-NCSA"
SLOT="stable"
KEYWORDS="~amd64 ~x86"

IUSE="clang debug doc libcxx system-llvm"
REQUIRED_USE="libcxx? ( clang )"

CDEPEND="libcxx? ( sys-libs/libcxx )
	>=app-eselect/eselect-rust-0.3_pre20150425
	!dev-lang/rust:0
"
DEPEND="${CDEPEND}
	${PYTHON_DEPS}
	>=dev-lang/perl-5.0
	clang? ( sys-devel/clang )
	system-llvm? ( =sys-devel/llvm-9999[multitarget(-)] )
"
RDEPEND="${CDEPEND}"

S=${WORKDIR}/${MY_P}

src_unpack() {
	unpack "${MY_P}-src.tar.gz" || die
	mkdir "${MY_P}/dl" || die
	cp "${DISTDIR}/rust-stage0"* "${MY_P}/dl/" || die
}

src_prepare() {
	local postfix="gentoo-${SLOT}"
	sed -i -e "s/CFG_FILENAME_EXTRA=.*/CFG_FILENAME_EXTRA=${postfix}/" mk/main.mk || die
}

src_configure() {
	export CFG_DISABLE_LDCONFIG="notempty"

	"${ECONF_SOURCE:-.}"/configure \
		--prefix="${EPREFIX}/usr" \
		--libdir="${EPREFIX}/usr/lib/${P}" \
		--mandir="${EPREFIX}/usr/share/${P}/man" \
		--release-channel=${SLOT} \
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
		$(usex system-llvm "--llvm-root=${EPREFIX}/usr" " ") \
		|| die
}

src_compile() {
	emake VERBOSE=1
}

src_install() {
	unset SUDO_USER

	default

	mv "${D}/usr/bin/rustc" "${D}/usr/bin/rustc-${PV}" || die
	mv "${D}/usr/bin/rustdoc" "${D}/usr/bin/rustdoc-${PV}" || die
	mv "${D}/usr/bin/rust-gdb" "${D}/usr/bin/rust-gdb-${PV}" || die

	dodoc COPYRIGHT LICENSE-APACHE LICENSE-MIT

	# le kludge that fixes https://github.com/Heather/gentoo-rust/issues/41
	mv "${D}/usr/lib/rust-${PV}/rust-${PV}/rustlib"/* "${D}/usr/lib/rust-${PV}/rustlib/" || die
	rmdir "${D}/usr/lib/rust-${PV}/rust-${PV}/rustlib" || die
	mv "${D}/usr/lib/rust-${PV}/rust-${PV}/"/* "${D}/usr/lib/rust-${PV}/" || die
	rmdir "${D}/usr/lib/rust-${PV}/rust-${PV}/" || die

	dodir "/usr/share/doc/rust-${PV}/"
	mv "${D}/usr/share/doc/rust"/* "${D}/usr/share/doc/rust-${PV}/" || die
	rmdir "${D}/usr/share/doc/rust/" || die

	cat <<-EOF > "${T}"/50${P}
	LDPATH="/usr/lib/${P}"
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
