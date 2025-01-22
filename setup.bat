del /s /f /q build\*.*
for /f %%f in ('dir /ad /b build\') do rd /s /q build\%%f

cmake -S . -B build -DCMAKE_TOOLCHAIN_FILE="D:\Programmation\vcpkg\scripts\buildsystems\vcpkg.cmake"
