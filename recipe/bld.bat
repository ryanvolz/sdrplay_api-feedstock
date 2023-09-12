setlocal EnableDelayedExpansion
@echo on

cd binary

sdrplay_api.exe /sp- /verysilent /suppressmsgboxes /norestart /currentuser /log="sdrplay_api_log.txt" /dir="%SRC_DIR%/sdrplay_api"
if errorlevel 1 exit 1

cd ../sdrplay_api

cmake -E copy "%RECIPE_DIR%/SDRplay_EULA" ../

cmake -E copy_directory "API/inc" "%LIBRARY_INC%"
cmake -E copy "API/x64/sdrplay_api.dll" "%LIBRARY_BIN%"
cmake -E copy "API/x64/sdrplay_api.lib" "%LIBRARY_LIB%"
cmake -E make_directory "%LIBRARY_SHARE%/sdrplay"
cmake -E copy_directory "Drivers" "%LIBRARY_SHARE%/sdrplay/drivers/"
cmake -E copy_directory "API/docs" "%LIBRARY_SHARE%/sdrplay/docs/"
cmake -E copy "sdrplay_apiService.exe" "%LIBRARY_BIN%"
cmake -E copy "RestartService.bat" "%LIBRARY_BIN%/sdrplay_RestartService.bat"
if errorlevel 1 exit 1
