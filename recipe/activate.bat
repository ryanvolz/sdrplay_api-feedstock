@echo off

set "SDRPLAY_API_VERSION=@SDRPLAY_API_VERSION@"
set "SDRPLAY_API_URL=@SDRPLAY_API_URL@"
set "target_platform=@target_platform@"

if defined CI (
  set "CONDA_BUILD_SDRPLAY_API=%TEMP%\cf-ci-sdrplay"
)

if not defined CONDA_BUILD_SDRPLAY_API (
  echo "CONDA_BUILD_SDRPLAY_API" is not set.
  exit /b 0
)

echo By setting CONDA_BUILD_SDRPLAY_API, you are agreeing to the terms and conditions of the SDRplay API end-user license agreement.

set "SDRPLAY_PREFIX=%CONDA_BUILD_SDRPLAY_API%\sdrplay_api-%SDRPLAY_API_VERSION%"

if not exist "%SDRPLAY_PREFIX%\" (
  md "%SDRPLAY_PREFIX%"
  pushd "%SDRPLAY_PREFIX%" > nul
    curl -o sdrplay_api.exe "%SDRPLAY_API_URL%"
    md tmp
    sdrplay_api.exe /sp- /verysilent /suppressmsgboxes /norestart /currentuser /log="sdrplay_api_log.txt" /dir="tmp\sdrplay_api"
    if errorlevel 1 exit /b 1
    pushd tmp\sdrplay_api > nul
      md "%SDRPLAY_PREFIX%\bin"
      robocopy "API\x64" "%SDRPLAY_PREFIX%\bin" "sdrplay_api.dll" /copyall > nul
      robocopy . "%SDRPLAY_PREFIX%\bin" "sdrplay_apiService.exe" /copyall > nul
      copy "RestartService.bat" "%SDRPLAY_PREFIX%\bin\sdrplay_RestartService.bat"
      md "%SDRPLAY_PREFIX%\include"
      robocopy "API\inc" "%SDRPLAY_PREFIX%\include" /e /copyall > nul
      md "%SDRPLAY_PREFIX%\lib"
      robocopy "API\x64" "%SDRPLAY_PREFIX%\lib" "sdrplay_api.lib" /copyall > nul
      md "%SDRPLAY_PREFIX%\share\sdrplay\drivers"
      robocopy "Drivers" "%SDRPLAY_PREFIX%\share\sdrplay\drivers" /e /copyall > nul
      md "%SDRPLAY_PREFIX%\share\sdrplay\docs"
      robocopy "API\docs" "%SDRPLAY_PREFIX%\share\sdrplay\docs" /e /copyall > nul
      if errorlevel 1 exit /b 1
    popd > nul
    rd /s /q tmp
  popd > nul
)
