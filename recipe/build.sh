#!/usr/bin/env bash

set -ex

cd binary

if [[ $target_platform == linux* ]] ; then
    installer=$(ls SDRplay*)
    installer_name=$(basename $installer .run)
    7z x "$installer"
    7z x "$installer_name"

    if [[ $target_platform == linux-64 ]] ; then
        arch_dir="x86_64"
    elif [[ $target_platform == linux-aarch64 ]] ; then
        arch_dir="aarch64"
    fi

    cmake -E copy "sdrplay_license.txt" "$SRC_DIR/SDRplay_EULA"

    cmake -E copy "$arch_dir/sdrplay_apiService" "$PREFIX/bin/"
    cmake -E copy_directory "inc" "$PREFIX/include/"
    cmake -E make_directory "$PREFIX/lib/udev/rules.d/"
    cmake -E copy "66-mirics.rules" "$PREFIX/lib/udev/rules.d/"
    cmake -E copy "$(ls $arch_dir/libsdrplay_api.so*)" "$PREFIX/lib/"
    pushd "$PREFIX/lib"
    cmake -E create_symlink "$(ls libsdrplay_api.so*)" "libsdrplay_api.so.3"
    cmake -E create_symlink "libsdrplay_api.so.3" "libsdrplay_api.so"
    popd
    cmake -E make_directory "$PREFIX/share/sdrplay/scripts"
    if [[ $target_platform == linux-64 ]] ; then
        cmake -E copy_directory "scripts" "$PREFIX/share/sdrplay/scripts/"
    else
        cmake -E copy "sdrplay.service.local" "$PREFIX/share/sdrplay/scripts/"
        cmake -E copy "sdrplay.service.usr" "$PREFIX/share/sdrplay/scripts/"
        cmake -E copy "sdrplayService_local" "$PREFIX/share/sdrplay/scripts/"
        cmake -E copy "sdrplayService_usr" "$PREFIX/share/sdrplay/scripts/"
    fi

elif [[ $target_platform == osx* ]] ; then
    installer=$(ls SDRplay*)
    7z x "$installer"
    7z x "Payload~"

    cd "$(ls -d Library/SDRplayAPI/3*)"

    if [[ $target_platform == osx-64 ]] ; then
        arch="x86_64"
    else
        arch="arm64"
    fi

    # strip universal binaries down to the specific architecture
    pushd lib
    libname="$(ls libsdrplay_api.so*)"
    libname_arch="${libname%%.*}_${arch}.${libname#*.}"
    # fix library name to match internal name, stripping the last version part of 3
    libname_arch="${libname_arch%.*}"
    cmake -E rename "$libname" "$libname.orig"
    lipo -thin $arch -output "$libname_arch" "$libname.orig"
    popd

    pushd bin
    cmake -E rename "sdrplay_apiService" "sdrplay_apiService.orig"
    lipo -thin $arch -output "sdrplay_apiService" "sdrplay_apiService.orig"
    popd

    cmake -E copy "LICENCE.txt" "$SRC_DIR/SDRplay_EULA"

    cmake -E make_directory "$PREFIX/bin/"
    cmake -E copy "bin/sdrplay_apiService" "$PREFIX/bin/"
    cmake -E make_directory "$PREFIX/include/"
    cmake -E copy_directory "inc" "$PREFIX/include/"
    cmake -E make_directory "$PREFIX/lib/"
    cmake -E copy "lib/$libname_arch" "$PREFIX/lib/"
    pushd "$PREFIX/lib"
    cmake -E create_symlink "$libname_arch" "$libname"
    cmake -E create_symlink "$libname" "libsdrplay_api.so.3"
    cmake -E create_symlink "libsdrplay_api.so.3" "libsdrplay_api.so"
    cmake -E create_symlink "libsdrplay_api.so" "libsdrplay_api.dylib"
    popd
fi
