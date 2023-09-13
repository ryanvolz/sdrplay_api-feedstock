@echo on

md "%LIBRARY_PREFIX%\share\doc\sdrplay_api"
copy "%RECIPE_DIR%\SDRplay_EULA" "%LIBRARY_PREFIX%\share\doc\sdrplay_api\copyright"
if errorlevel 1 exit 1

md "%PREFIX%\etc\conda\activate.d"
copy "%RECIPE_DIR%\activate.bat" "%PREFIX%\etc\conda\activate.d\sdrplay_api_activate.bat"
if errorlevel 1 exit 1
pushd "%PREFIX%\etc\conda\activate.d"
sed -i "s|@SDRPLAY_API_VERSION@|%SDRPLAY_API_VERSION%|g" sdrplay_api_activate.bat
sed -i "s|@SDRPLAY_API_URL@|%SDRPLAY_API_URL%|g" sdrplay_api_activate.bat
sed -i "s|@target_platform@|%target_platform%|g" sdrplay_api_activate.bat
if errorlevel 1 exit 1
popd
