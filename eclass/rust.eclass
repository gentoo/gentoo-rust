# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: rust.eclass
# @MAINTAINER:
# rust@gentoo.org
# @AUTHOR:
# gibix <gibix@riseup.net>
# A common eclass providing helper functions to build and install
# packages supporting being installed for multiple rust
# implementations.

case "${EAPI:-0}" in
	1|1|2|3|4|5|6|7)
		;;
	*)
		die "Unsupported EAPI=${EAPI} (unknown) for ${ECLASS}"
		;;
esac

inherit multibuild rust-utils

export pkg_setup

# @ECLASS-VARIABLE: RUST_COMPAT
# @REQUIRED
# @DESCRIPTION:
# This variable contains a list of Rust implementations the package
# supports. It must be set before the `inherit' call. It has to be
# an array.
#
# Example:
# @CODE
# RUST_COMPAT=( rust1_{25, 26, 27} )
# @CODE
#

# @FUNCTION: rust_setup
# @DESCRIPTION:
# does tut cos
rust_setup() {
	local rustcompat=( "${RUST_COMPAT[@]}" )

	_rust_set_impls

	# (reverse iteration -- newest impl first)
	local found
	for (( i = ${#_RUST_SUPPORTED_IMPLS[@]} - 1; i >= 0; i-- )); do
		local impl=${_RUST_SUPPORTED_IMPLS[i]}

		# check RUST_COMPAT[_OVERRIDE]
		has "${impl}" "${rustcompat[@]}" || continue

		# check patterns
		# _rust_impl_matches "${impl}" "${@-*}" || continue

		elog "${impl}"
		rust_export "${impl}"

		found=1
		break
	done

	if [[ ! ${found} ]]; then
		eerror "${FUNCNAME}: none of the enabled implementation matched the patterns."
		eerror "  patterns: ${@-'(*)'}"
		eerror "Likely a REQUIRED_USE constraint (possibly USE-conditional) is missing."
		eerror "  suggested: || ( \$(rust_gen_useflags ${@}) )"
		eerror "(remember to quote all the patterns with '')"
		die "${FUNCNAME}: no enabled implementation satisfy requirements"
	fi
}
