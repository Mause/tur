TERMUX_PKG_HOMEPAGE=https://docs.astral.sh/ty/
TERMUX_PKG_DESCRIPTION="An extremely fast Python typechecker, written in Rust."
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_LICENSE_FILE="../../LICENSE"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION="0.0.1-alpha.11"
TERMUX_PKG_SRCURL=https://github.com/astral-sh/ty/releases/download/${TERMUX_PKG_VERSION}/source.tar.gz
TERMUX_PKG_SHA256=9c7a94a7a8b9266c8421847f4b9b4a754124a54b2d668005a828c1e7e2fd6346
TERMUX_PKG_DEPENDS="zstd"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true

termux_step_post_get_source() {
	TERMUX_PKG_SRCDIR+="/crates/ty"
}

termux_step_pre_configure() {
	termux_setup_rust

	# Dummy CMake toolchain file to workaround build error:
	# error: failed to run custom build command for `libz-ng-sys v1.1.15`
	# ...
	# CMake Error at /home/builder/.termux-build/_cache/cmake-3.28.3/share/cmake-3.28/Modules/Platform/Android-Determine.cmake:217 (message):
	# Android: Neither the NDK or a standalone toolchain was found.
	export TARGET_CMAKE_TOOLCHAIN_FILE="${TERMUX_PKG_BUILDDIR}/android.toolchain.cmake"
	touch "${TERMUX_PKG_BUILDDIR}/android.toolchain.cmake"

	: "${CARGO_HOME:=$HOME/.cargo}"
	export CARGO_HOME
}

termux_step_make() {
	cd "$TERMUX_PKG_SRCDIR"

	PKG_CONFIG_PATH="/usr/lib/x86_64-linux-gnu/pkgconfig/" \
	PKG_CONFIG_ALL_DYNAMIC=1 \
	ZSTD_SYS_USE_PKG_CONFIG=1 \
	cargo build --jobs "${TERMUX_PKG_MAKE_PROCESSES}" --target "${CARGO_TARGET_NAME}" --release --verbose
}

termux_step_make_install() {
	install -Dm700 -t "${TERMUX_PREFIX}"/bin target/"${CARGO_TARGET_NAME}"/release/ty
}
