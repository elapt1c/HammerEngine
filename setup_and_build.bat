@echo off
SET MSYS2_PATH=C:\msys64
SET MINGW_BIN=%MSYS2_PATH%\mingw64\bin

:: 1. Ask the user for the path to the demo folder
echo --------------------------------------------------
set /p DEMO_PATH="Enter the full path to your demo folder: "
echo --------------------------------------------------

:: Verify the path exists
if not exist "%DEMO_PATH%" (
    echo [ERROR] The path "%DEMO_PATH%" does not exist.
    pause
    exit /b
)

:: 2. Check/Install MSYS2
if exist "%MSYS2_PATH%" (
    echo [INFO] MSYS2 found. Skipping installation.
) else (
    echo [INFO] MSYS2 not found. Downloading installer...
    powershell -Command "Invoke-WebRequest -Uri https://github.com/msys2/msys2-installer/releases/download/2024-01-13/msys2-x86_64-20240113.exe -OutFile msys2_installer.exe"
    echo [INFO] Installing MSYS2...
    start /wait msys2_installer.exe --confirm-command --accept-messages --root %MSYS2_PATH%
    del msys2_installer.exe
)

:: 3. Install GCC and Libraries
echo [INFO] Ensuring GCC and dependencies are installed...
%MSYS2_PATH%\usr\bin\bash.exe -lc "pacman -S --noconfirm --needed mingw-w64-x86_64-gcc mingw-w64-x86_64-cmake mingw-w64-x86_64-make mingw-w64-x86_64-vulkan-loader mingw-w64-x86_64-glfw mingw-w64-x86_64-glm"

:: 4. Build Process
set PATH=%MINGW_BIN%;%PATH%
cd /d "%DEMO_PATH%"

if not exist build mkdir build
cd build

echo [INFO] Running CMake in %DEMO_PATH%...
cmake -G "MinGW Makefiles" -DCMAKE_C_COMPILER=gcc -DCMAKE_CXX_COMPILER=g++ ..
mingw32-make

echo ---------------------------------------
echo [SUCCESS] Build complete for demo at:
echo %DEMO_PATH%\build
echo ---------------------------------------
pause
