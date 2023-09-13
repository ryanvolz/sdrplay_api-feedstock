#!/usr/bin/env bash

set -ex

mkdir -p "${PREFIX}/share/doc/sdrplay_api"
cp "${RECIPE_DIR}/SDRplay_EULA" "${PREFIX}/share/doc/sdrplay_api/copyright"

mkdir -p "${PREFIX}/etc/conda/activate.d"
cp "${RECIPE_DIR}/activate.sh" "sdrplay_api_activate.sh"
sed -i.bak "s|@SDRPLAY_API_VERSION@|$SDRPLAY_API_VERSION|g" "sdrplay_api_activate.sh"
sed -i.bak "s|@SDRPLAY_API_URL@|$SDRPLAY_API_URL|g" "sdrplay_api_activate.sh"
sed -i.bak "s|@target_platform@|$target_platform|g" "sdrplay_api_activate.sh"
cp "sdrplay_api_activate.sh" "${PREFIX}/etc/conda/activate.d/sdrplay_api_activate.sh"
