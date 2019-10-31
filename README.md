Rust overlay
============

[![Build Status](https://travis-ci.org/gentoo/gentoo-rust.png?branch=master)](https://travis-ci.org/gentoo/gentoo-rust) [![Gentoo discord server](https://img.shields.io/discord/249111029668249601.svg?style=flat-square&label=Gentoo%20Linux)](https://discord.gg/Gentoo)

# Update

Overlay has been moved to the new [address](https://gitweb.gentoo.org/repo/proj/rust.git).
No user interaction is needed, layman will handle this automatically. Please, report any issues
and make pull requests in the new repo.

# User's guide

## Adding the overlay

This [overlay](https://wiki.gentoo.org/wiki/Overlay) is available through [layman](https://wiki.gentoo.org/wiki/Layman).

To use packages from it, add it with

```
layman -a rust
```

If you use [eix](https://wiki.gentoo.org/wiki/Eix) you may need to execute

```
eix-update
```

after it.

## Packages

This overlay contains Rust compiler and Rust related packages and is the primary place for developing of the Rust infrastructure on Gentoo.

As user you may be interested in these packages:

* `dev-lang/rust` Rust compiler built from sources
* `dev-lang/rust-bin` Binary packaged Rust compiler
* `dev-util/cargo` Cargo rust package manager and build tool
* `dev-util/cargo-bin` Binary packaged cargo rust package manager and build tool

There are other useful packages in this overlay, use `eix` or whatever else to learn about them.

## Rust compiler implementations

Different Rust versions can be installed simultaneously on Gentoo.
[Slots](https://devmanual.gentoo.org/general-concepts/slotting/) and
[eselect](https://wiki.gentoo.org/wiki/Project:Eselect) are used for this purpose.
To learn more, see [eselect-rust](https://github.com/jauhien/eselect-rust).

Useful `USE flags`.

### `dev-lang/rust`

* `doc` install documentation
* `system-llvm` use system LLVM (will decrease compilation time)

### `dev-lang/rust-bin`

* `cargo-bundled` install bundled Cargo
* `doc` install documentation

# Developer's guide

## Contributing

Fork this repo and make a pull request. We are happy to merge it.

Please, make sure you've read [devmanual](https://devmanual.gentoo.org/).

Commit message should look like

```
[category/packagename] short decription

Long description
```

This makes reading history easier. GPG signing your changes is a good idea.

If you have push access to this repo it is a good idea to still create a pull request,
so at least one more person have reviewed your code.
Exceptions are trivial changes and urgent changes (that fix something completely broken).

## Communication

 - Join #gentoo-rust channel on Freenode
 - Open issues here https://github.com/gentoo/gentoo-rust
 - Gentoo Discord: https://discord.gg/KEphgqH

## Slotting

Currently we have these slots for `dev-lang/rust`:

* `stable` -- stable release
* `git` -- upstream git version

Note, that source packages use a custom postfix for Rust libraries.
This is important, as otherwise simultaneously installed different Rust versions will fail to work.
An example of `src_prepare` that sets appropriate postfixes:

```
src_prepare() {
	local postfix="gentoo-${SLOT}"
	sed -i -e "s/CFG_FILENAME_EXTRA=.*/CFG_FILENAME_EXTRA=${postfix}/" mk/main.mk || die
}
```

For `dev-lang/rust-bin` slots are:

* `stable` -- stable release
* `beta` -- beta version
* `nightly` -- nightly version

Note, that `cargo-bundled` USE is available only for `nightly` and `beta` `dev-lang/rust-bin`
and `cargo` binary is not under the eselect control, so `nightly` and `beta` cannot have `cargo-bundled`
USE enabled at the same time.

## Eselect-rust

Rust compiler packages use [eselect-rust](https://github.com/jauhien/eselect-rust) to managed their symlinks.
Consult its README for information on how to properly register your package in eselect.

You need to set active Rust version in `pkg_postinst` if no one were set before:

```
eselect rust update --if-unset
```

You need to unset active Rust version in `pkg_postrm` if it were the one you just removed:

```
eselect rust unset --if-invalid
```

## Environment

You need to set `MANPATH` and `LDPATH` appropriately. See existing ebuilds.

## Testing

Please, make sure you have checked this before creating pull request:

* you've run `repoman full -d` and it didn't complain about errors
* you've emerged ebuild with your changes and it was installed correctly
* you've run the stuff your ebuild installed and it worked for you
* if you have keywords in your ebuild, you have tested it for every ARCH mentioned there

## Changes propagation to the tree

Changes in the packages available in the main Gentoo tree will propagate there after some time (usually one week).
At the moment these packages are:

* app-emacs/rust-mode
* app-eselect/eselect-rust
* app-shells/rust-zshcomp
* app-vim/rust-mode
* dev-lang/rust
* dev-lang/rust-bin
