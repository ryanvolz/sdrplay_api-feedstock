#!/usr/bin/env bash

SDRPLAY_API_VERSION=@SDRPLAY_API_VERSION@
SDRPLAY_API_URL=@SDRPLAY_API_URL@
target_platform=@target_platform@

[ -z "${CI}" ] || export CONDA_BUILD_SDRPLAY_API=/tmp/cf-ci-sdrplay

if [[ -z "${CONDA_BUILD_SDRPLAY_API}" ]]; then
    echo "CONDA_BUILD_SDRPLAY_API" is not set.
    # exit gracefully whether this script is sourced (return) or executed (exit)
    return 0 2>/dev/null
    exit 0
fi

echo "By setting CONDA_BUILD_SDRPLAY_API, you are agreeing to the terms and conditions of the SDRplay API end-user license agreement."

export SDRPLAY_PREFIX="${CONDA_BUILD_SDRPLAY_API}/sdrplay_api-$SDRPLAY_API_VERSION"

if [[ ! -d "${SDRPLAY_PREFIX}" ]]; then
  mkdir -p "${SDRPLAY_PREFIX}"
  pushd "${SDRPLAY_PREFIX}" > /dev/null
    curl -L -O $SDRPLAY_API_URL
    installer=$(ls SDRplay*)
    installer_name=$(basename $installer .run)

    mkdir tmp
    pushd tmp > /dev/null
      if [[ $target_platform == linux* ]] ; then
        if [[ $target_platform == linux-64 ]] ; then
          arch="x86_64"
        elif [[ $target_platform == linux-aarch64 ]] ; then
          arch="aarch64"
        fi

        7z x "../$installer" -aoa > /dev/null
        7z x "$installer_name" -aoa > /dev/null

        mv "sdrplay_license.txt" "$SDRPLAY_PREFIX/SDRplay_EULA"

        mkdir -p "$SDRPLAY_PREFIX/bin"
        mv "$arch/sdrplay_apiService" "$SDRPLAY_PREFIX/bin/"
        mv "inc" "$SDRPLAY_PREFIX/include"
        mkdir -p "$SDRPLAY_PREFIX/lib/udev/rules.d"
        mv "66-mirics.rules" "$SDRPLAY_PREFIX/lib/udev/rules.d/"
        mkdir -p "$SDRPLAY_PREFIX/lib"
        mv "$(ls $arch/libsdrplay_api.so*)" "$SDRPLAY_PREFIX/lib/"
        pushd "$SDRPLAY_PREFIX/lib" > /dev/null
          ln -s "$(ls libsdrplay_api.so*)" "libsdrplay_api.so.3"
          ln -s "libsdrplay_api.so.3" "libsdrplay_api.so"
        popd > /dev/null
        if [[ $target_platform == linux-64 ]] ; then
          mkdir -p "$SDRPLAY_PREFIX/share/sdrplay"
          mv "scripts" "$SDRPLAY_PREFIX/share/sdrplay/"
        else
          mkdir -p "$SDRPLAY_PREFIX/share/sdrplay/scripts"
          mv "sdrplay.service.local" "$SDRPLAY_PREFIX/share/sdrplay/scripts/"
          mv "sdrplay.service.usr" "$SDRPLAY_PREFIX/share/sdrplay/scripts/"
          mv "sdrplayService_local" "$SDRPLAY_PREFIX/share/sdrplay/scripts/"
          mv "sdrplayService_usr" "$SDRPLAY_PREFIX/share/sdrplay/scripts/"
        fi
      elif [[ $target_platform == osx* ]] ; then
        if [[ $target_platform == osx-64 ]] ; then
          arch="x86_64"
        elif [[ $target_platform == osx-arm64 ]] ; then
          arch="arm64"
        fi

        7z x "../$installer" -aoa > /dev/null
        7z x "Payload~" -aoa > /dev/null

        pushd "$(ls -d Library/SDRplayAPI/3*)" > /dev/null
          # strip universal binaries down to the specific architecture
          pushd lib > /dev/null
            libname="$(ls libsdrplay_api.so*)"
            mv "$libname" "$libname.orig"
            lipo -thin $arch -output "$libname" "$libname.orig"
            # change library's install name so it uses an rpath and is findable
            # under an installed name that the sdrplay installer uses
            # (use *.so.3 instead of *.so.3.12 because installer does not
            #  provide the latter even though it should)
            install_name_tool -id "@rpath/libsdrplay_api.so.3" "$libname"
          popd > /dev/null

          pushd bin > /dev/null
            mv "sdrplay_apiService" "sdrplay_apiService.orig"
            lipo -thin $arch -output "sdrplay_apiService" "sdrplay_apiService.orig"
          popd > /dev/null

          mv "LICENCE.txt" "$SDRPLAY_PREFIX/SDRplay_EULA"

          mkdir -p "$SDRPLAY_PREFIX/bin"
          mv "bin/sdrplay_apiService" "$SDRPLAY_PREFIX/bin/"
          mv "inc" "$SDRPLAY_PREFIX/include"
          mkdir -p "$SDRPLAY_PREFIX/lib"
          mv "lib/$libname" "$SDRPLAY_PREFIX/lib/"
          pushd "$SDRPLAY_PREFIX/lib" > /dev/null
            ln -s "$libname" "${libname%.*}"
            ln -s "$libname" "libsdrplay_api.so.3"
            ln -s "libsdrplay_api.so.3" "libsdrplay_api.so"
            ln -s "libsdrplay_api.so" "libsdrplay_api.dylib"
          popd > /dev/null
        popd > /dev/null
      fi
    popd > /dev/null
    rm -rf tmp
  popd > /dev/null
fi
