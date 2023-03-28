@echo off

if not "%1" == "" set module=%1

set SFML=static
set DEBUG=1
call "%~dp0_build_examples.cmd" %*

