@echo off
setlocal enabledelayedexpansion

if "%1" == "" (
	set "modules=src/*.cpp"
) else (
	set modules=src/%1
)

if "%CLFLAG%" == "" (
	echo - ERROR: CLFLAG must be set ^(to -MT or -MTd^)^!
	exit -1
)
set out=out.%CLFLAG%

set SFML=C:/SW/devel/lib/sfml/current
set THOR=.
set INCLUDE=%THOR%/include;%THOR%/extlibs/aurora/include;%SFML%/include;%INCLUDE%
rem Also for temp. SFML shims (like NonCopyable.hpp):
set INCLUDE=%THOR%/extlibs;%INCLUDE%
set LIB=%THOR%/lib;%SFML%/lib;%SFML%/lib/Debug;%LIB%

set SFML_LIBS=sfml-graphics-s%LIBFLAG%.lib sfml-window-s%LIBFLAG%.lib sfml-system-s%LIBFLAG%.lib ^
	sfml-audio-s%LIBFLAG%.lib ogg.lib vorbis.lib vorbisenc.lib vorbisfile.lib flac.lib openal32.lib ^
	opengl32.lib freetype.lib ^
	user32.lib kernel32.lib gdi32.lib winmm.lib advapi32.lib

::No support for this yet:
::set SFML_DLL_LIBS=sfml-graphics%LIBFLAG%.lib sfml-window%LIBFLAG%.lib sfml-system%LIBFLAG%.lib ^
::	sfml-audio%LIBFLAG%.lib ogg.lib vorbis.lib vorbisenc.lib vorbisfile.lib flac.lib openal32.lib ^
::	opengl32.lib

set THOR_LIB=%out%/thor.lib

for /f %%f in ('dir /b examples\*.cpp') do (
	cl -W4 -DSFML_STATIC -O2 -std:c++20 -%CLFLAG% -EHsc -Foexamples/ -Feexamples/ "examples/%%f" ^
		-link ^
		%THOR_LIB% ^
		%SFML_LIBS%
	if errorlevel 1 (
		echo - FAILED.
		goto :eof
	)
)
