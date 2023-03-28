@echo off
setlocal enabledelayedexpansion

if "%1" == "" (
	set "module=*.cpp"
) else (
	set module=%1.cpp
)

if "%SFML%" == "" (
	echo - ERROR: The `SFML` env. var. must be set to `static` or `dll`!
	exit -1
) else if "%SFML%" == "static" (
	set SFMLFLAG=-DSFML_STATIC
	set SFML_LIB_SUFFIX=-s
)
set out_suffix_sfml=.sfml-%SFML%

if "%DEBUG%" == "1" (
	set out_suffix_DEBUG=.DEBUG
	set SFML_LIB_SUFFIX=%SFML_LIB_SUFFIX%-d
	set CLFLAGS=-Zi -DDEBUG -MDd
) else (
	set CLFLAGS=-O2 -DNDEBUG -MD
)


set out=out
set objdir=%out%\obj%out_suffix_sfml%%out_suffix_DEBUG%

set SFML=C:/SW/devel/lib/sfml/current
set THOR=.
set INCLUDE=%THOR%/include;%THOR%/extlibs/aurora/include;%SFML%/include;%INCLUDE%
rem Also for temp. SFML shims (like NonCopyable.hpp):
set INCLUDE=%THOR%/extlibs;%INCLUDE%
set LIB=%THOR%/lib;%SFML%/lib;%SFML%/lib/Debug;%LIB%

set SFML_LIBS=sfml-graphics%SFML_LIB_SUFFIX%.lib sfml-window%SFML_LIB_SUFFIX%.lib sfml-system%SFML_LIB_SUFFIX%.lib ^
	sfml-audio%SFML_LIB_SUFFIX%.lib ogg.lib vorbis.lib vorbisenc.lib vorbisfile.lib flac.lib openal32.lib ^
	opengl32.lib freetype.lib ^
	user32.lib kernel32.lib gdi32.lib winmm.lib advapi32.lib

set THOR_LIB=%out%/thor%SFML_LIB_SUFFIX%.lib

for /f %%f in ('dir /b examples\%module%') do (
	cl -W4 -std:c++20 -EHsc %CLFLAGS% %SFMLFLAG% -Foexamples/ -Fdexamples/ -Feexamples/ "examples/%%f" ^
		-link ^
		%THOR_LIB% ^
		%SFML_LIBS%
	if errorlevel 1 (
		echo - FAILED.
		goto :eof
	)
)
