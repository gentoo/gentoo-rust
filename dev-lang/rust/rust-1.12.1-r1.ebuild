# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

PYTHON_COMPAT=( python2_7 )

inherit python-any-r1 versionator toolchain-funcs

if [[ ${PV} = *beta* ]]; then
	betaver=${PV//*beta}
	BETA_SNAPSHOT="${betaver:0:4}-${betaver:4:2}-${betaver:6:2}"
	MY_P="rustc-beta"
	SLOT="beta/${PV}"
	SRC="${BETA_SNAPSHOT}/rustc-beta-src.tar.gz"
	KEYWORDS=""
else
	ABI_VER="$(get_version_component_range 1-2)"
	SLOT="stable/${ABI_VER}"
	MY_P="rustc-${PV}"
	SRC="${MY_P}-src.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

STAGE0_VERSION="1.$(($(get_version_component_range 2) - 1)).0"
NEXT_VERSION="1.$(($(get_version_component_range 2) + 1)).0"

DESCRIPTION="Systems programming language from Mozilla"
HOMEPAGE="http://www.rust-lang.org/"

SRC_URI="https://static.rust-lang.org/dist/${SRC} -> rustc-${PV}-src.tar.gz"

LICENSE="|| ( MIT Apache-2.0 ) BSD-1 BSD-2 BSD-4 UoI-NCSA"

IUSE="clang debug doc libcxx +system-llvm source"
REQUIRED_USE="libcxx? ( clang )"

RDEPEND="libcxx? ( sys-libs/libcxx )
	system-llvm? ( >=sys-devel/llvm-3.9.0:= )
"

# We can't depend on virtual/rust for building because portage (as of
# 2.3.0) gets confused by the circular dependency when trying to
# upgrade.
DEPEND="${RDEPEND}
	${PYTHON_DEPS}
	>=dev-lang/perl-5.0
	clang? ( sys-devel/clang )
	|| (
		( >=dev-lang/rust-bin-${STAGE0_VERSION}:stable
		  <dev-lang/rust-bin-${NEXT_VERSION}:stable )
		( >=dev-lang/rust-${STAGE0_VERSION}:stable
		  <dev-lang/rust-${NEXT_VERSION}:stable )
	)
"

PDEPEND=">=app-eselect/eselect-rust-0.3_pre20150425"

S="${WORKDIR}/${MY_P}"

src_prepare() {
	find mk -name '*.mk' -exec \
		 sed -i -e "s/-Werror / /g" {} \; || die

	eapply "${FILESDIR}/${PN}-1.11.0-libdir-bootstrap.patch"

	eapply_user
}

src_configure() {
	# In order to compile itself, rustc needs to be passed a special
	# argument to allow the use of unstable language features.  This
	# argument varies by version, so we have to tell the build system
	# whether this is a recompile or an upgrade.
	local local_rebuild
	local installed_version="$("${EPREFIX}/usr/bin/rustc" --version)" || die
	case "${installed_version}" in
		"rustc ${PV}"*) local_rebuild=--enable-local-rebuild ;;
		"rustc ${STAGE0_VERSION}"*) ;;
		*)
			eerror "Selected rust (${installed_version}) cannot build"
			eerror "version ${PV}.  Please use version ${STAGE0_VERSION}"
			eerror "or ${PV}."
			die "Incompatible rust selected"
	esac

	export CFG_DISABLE_LDCONFIG="notempty"

	"${ECONF_SOURCE:-.}"/configure \
		--prefix="${EPREFIX}/usr" \
		--libdir="${EPREFIX}/usr/$(get_libdir)/${P}" \
		--mandir="${EPREFIX}/usr/share/${P}/man" \
		--release-channel=${SLOT%%/*} \
		--disable-manage-submodules \
		--default-linker=$(tc-getBUILD_CC) \
		--default-ar=$(tc-getBUILD_AR) \
		--python=${EPYTHON} \
		--disable-rpath \
		--enable-local-rust \
		--local-rust-root="${EPREFIX}/usr" \
		${local_rebuild} \
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

	dodoc COPYRIGHT

	dodir "/usr/share/doc/rust-${PV}/"
	mv "${D}/usr/share/doc/rust"/* "${D}/usr/share/doc/rust-${PV}/" || die
	rmdir "${D}/usr/share/doc/rust/" || die

	cat <<-EOF > "${T}"/50${P}
	LDPATH="/usr/$(get_libdir)/${P}"
	MANPATH="/usr/share/${P}/man"
	EOF
	if use source; then
		cat <<-EOF >> "${T}"/50${P}
		RUST_SRC_PATH="/usr/share/${P}/src"
		EOF
	fi
	doenvd "${T}"/50${P}

	cat <<-EOF > "${T}/provider-${P}"
	/usr/bin/rustdoc
	/usr/bin/rust-gdb
	EOF
	dodir /etc/env.d/rust
	insinto /etc/env.d/rust
	doins "${T}/provider-${P}"

	if use source; then
		dodir /usr/share/${P}
		cp -R "${S}/src" "${D}/usr/share/${P}"
	fi
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
