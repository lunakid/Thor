#### MSVC Jumpstart Makefile, r12                              (Public Domain)
#### -> https://github.com/xparq/NMAKE-Jumpstart
####
#### BEWARE! Uses recursive NMAKE invocations, so update the macro below if
#### you rename this file:
THIS_MAKEFILE=Makefile

#-----------------------------------------------------------------------------
# Config - Project layout
#
# Note: the cfg. options can't be set on the NMAKE command line, only here!
#-----------------------------------------------------------------------------
PRJ_NAME=thor
# Use the lower-case (processed) path macros here:
main_lib=$(lib_dir)\$(PRJ_NAME)$(buildmode_file_suffix).lib
#main_exe=$(exe_dir)\$(PRJ_NAME)$(buildmode_file_suffix).exe
# Main targets to build:
BUILD = $(main_lib)

SRC_DIR=src
OUT_DIR=out
LIB_DIR=$(OUT_DIR)
EXE_DIR=$(OUT_DIR)
OBJ_DIR=$(OUT_DIR)/obj
CXX_MOD_IFC_DIR=$(OUT_DIR)/ifc
# Put (only) these into the lib (relative to SRC_DIR; leave it empty for "all"):
LIB_SRC_SUBDIR=

# Source (translation unit) basename filter:
UNITS_PATTERN=*

# External dependencies:
EXT_INCLUDE_DIRS=extlibs\aurora\include;extlibs\SFML\include;extlibs
EXT_LIB_DIRS=extlibs\SFML\lib
EXT_LIBS=

#-----------------------------------------------------------------------------
# Config - Build options
#-----------------------------------------------------------------------------
# Build alternatives (override from the command-line, too, if needed):
DEBUG=0
# ...but don't change this one, as CRT=dll is always the case with the pre-built SFML libs:
CRT=dll
SFML=static
# Custom build options need to be passed along for recursion explicitly:
custom_build_options = SFML=$(SFML)

# Comp. flags:
CFLAGS=-W4 -Iinclude
CXXFLAGS=-std:c++latest
# Note: C++ compilation would use $(CFLAGS), too.

!if "$(SFML)" == "static"
CFLAGS=$(CFLAGS) -DSFML_STATIC
buildmode_file_suffix=-s
!endif

# Output dir/file suffixes for build alternatives
SFML_linkmode=$(SFML)
buildmode_dir_suffix=.sfml-$(SFML_linkmode)
# NOTE: Must differ from their "no ..." counterparts to avoid code (linking)
#       mismatches!
buildmode_debug_dir_suffix=.DEBUG
buildmode_debug_file_suffix=-d
# No point marking these, as CRT=dll is always the case with the pre-built SFML libs:
buildmode_crtdll_dir_suffix=
buildmode_crtdll_file_suffix=

#=============================================================================
#                     NO EDITS NEEDED BELOW, NORMALLY...
#=============================================================================
obj_source_exts=cpp cxx c

#-----------------------------------------------------------------------------
# Show current processing stage...
#-----------------------------------------------------------------------------
!ifdef RECURSED_FOR_COMPILING
!if "$(DIR)" == ""
node=(main)
!else
node="$(DIR)"
!endif
!message Processing source dir: $(node)...
!endif

#-----------------------------------------------------------------------------
# Normalize the (prj-local) paths before potentially passing them to any of
# the arcane "DOS" commands only to make them choke on fwd. slashes!...
# + Also guard against accidental \ prefixes for empty dirs!
#   (Note: \ needs to be escaped here. Quoted paths are NOT handled here,
#   because those couldn't be used later anyway for appending ubdirs to them,
#   so quoting is assumed to be handled at the last moment, when passing the
#   paths to the commands!)
#-----------------------------------------------------------------------------
#! Not prefixdir=$(MAKEDIR), as most of these are subdirs!
prefixdir=.
#! This is still too hamfisted if some were in fact ment to be absolute paths!
#! Anyway, at leat it's erring on the safe side.
src_dir         = $(prefixdir)\$(patsubst \\%,%,$(SRC_DIR:/=\))
out_dir         = $(prefixdir)\$(patsubst \\%,%,$(OUT_DIR:/=\))
lib_dir         = $(prefixdir)\$(patsubst \\%,%,$(LIB_DIR:/=\))
exe_dir         = $(prefixdir)\$(patsubst \\%,%,$(EXE_DIR:/=\))
obj_dir         = $(prefixdir)\$(patsubst \\%,%,$(OBJ_DIR:/=\))
cxx_mod_ifc_dir = $(prefixdir)\$(patsubst \\%,%,$(CXX_MOD_IFC_DIR:/=\))
!if "$(main_lib)" != ""
main_lib        = $(prefixdir)\$(patsubst \\%,%,$(main_lib:/=\))
!endif
!if "$(main_exe)" != ""
main_exe        = $(prefixdir)\$(patsubst \\%,%,$(main_exe:/=\))
!endif
# And this one is really a subdir, which will be prefixed internally with src_dir,
# so don't mess it up with the same adjustment, just normalize the slashes:
lib_src_subdir  = $(LIB_SRC_SUBDIR:/=\)

# Now, this one, OTOH, must be the normalized *full* path of the src root:
#   srcroot_fullpath = $(MAKEDIR)\$(src_dir)
# -- used in the command blocks for abs->rel conversion (via direct path
# string replacement in the tree traversal loops), which needs to be as
# robust as possible! (And are still too brittle!...)
# Except...: if the path contains spaces, then it's considered a list,
# and each item would get separately normalized! (Quoting doesn't help! :-/ )
# So... Behold this shameless abomination of a workaround:
_SPACE_=$(subst x,,x x)
p=$(subst $(_SPACE_),<FAKE_SPACE>,$(MAKEDIR)\$(src_dir))
srcroot_fullpath=$(subst <FAKE_SPACE>,$(_SPACE_),$(abspath $(p)))

#-----------------------------------------------------------------------------
# Set/adjust tool options (according to the config)...
#-----------------------------------------------------------------------------
# Preserve the original NMAKE flags & explicitly supported macros on recursion:
MAKE_CMD=$(MAKE) /nologo /$(MAKEFLAGS) /f $(THIS_MAKEFILE) DEBUG=$(DEBUG) CRT=$(CRT)

CFLAGS=-nologo -c $(CFLAGS)
CXXFLAGS=-EHsc $(CXXFLAGS)
!if "$(cxx_mod_ifc_dir)" != ""
CXXFLAGS=-ifcSearchDir $(cxx_mod_ifc_dir) $(CXXFLAGS)
!endif

#----------------------------
# Static/DLL CRT link mode
#------
!if "$(CRT)" == "static"
_cflags_crt_linkmode=-MT
!else if "$(CRT)" == "dll"
_cflags_crt_linkmode=-MD
!else
!error Unknown CRT link mode: $(CRT)!
!endif

#----------------------
# DEBUG/RELEASE mode
#------
cflags_debug_0=$(_cflags_crt_linkmode) -O2 -DNDEBUG
# The -O...s below are taken from Dr. Memory's README/Quick start.
# -ZI enables edit-and-continue (but it only exists for Intel CPUs!).
cflags_debug_1=$(_cflags_crt_linkmode)d -ZI -Od -Oy- -Ob0 -RTCsu -DDEBUG -Fd$(out_dir)/
linkflags_debug_0=
linkflags_debug_1=-debug -incremental -editandcontinue -ignore:4099

!if defined(DEBUG) && $(DEBUG) == 1
_cflags_debugmode=$(cflags_debug_1)
_linkflags_debugmode=$(linkflags_debug_1)
!else if $(DEBUG) == 0
_cflags_debugmode=$(cflags_debug_0)
_linkflags_debugmode=$(linkflags_debug_0)
!else
!error Unknown debug mode: $(DEBUG)!
!endif

CFLAGS=$(_cflags_debugmode) $(CFLAGS)
LINKFLAGS=$(_linkflags_debugmode) $(LINKFLAGS)

#---------------------------------------
# External include & lib search paths
#------
!if "$(EXT_INCLUDE_DIRS)" != ""
!if [set INCLUDE=%INCLUDE%;$(EXT_INCLUDE_DIRS)]
!endif
!endif

!if "$(EXT_LIB_DIRS)" != ""
!if [set LIB=%LIB%;$(EXT_LIB_DIRS)]
!endif
!endif
# Or, alternatively:
#!if "$(EXT_LIB_DIRS)" != ""
#LINKFLAGS=$(LINKFLAGS) -libpath:$(EXT_LIB_DIRS)
#!endif

#-----------------------------------------------------------------------------
# Split the target tree across build alternatives...
#!! Would be nice to just split the root, but the libs and exes can be
#!! off the tree (for convenience & flexibility, e.g. differentiated by name
#!! suffixes etc.)... Which leaves us with dispatching the obj_dir instead
#!! -- and leaving the lib_dir and exe_dir totally ignored... :-/
#-----------------------------------------------------------------------------
# For the output dirs (currently only the obj. dir), and
# for the output files (currently the lib/exe files)
!if "$(CRT)" == "dll"
buildmode_dir_suffix=$(buildmode_dir_suffix)$(buildmode_crtdll_dir_suffix)
buildmode_file_suffix=$(buildmode_file_suffix)$(buildmode_crtdll_file_suffix)
!endif

!if "$(DEBUG)" == "1"
buildmode_dir_suffix=$(buildmode_dir_suffix)$(buildmode_debug_dir_suffix)
buildmode_file_suffix=$(buildmode_file_suffix)$(buildmode_debug_file_suffix)
!endif

obj_dir=$(obj_dir)$(buildmode_dir_suffix)

#-----------------------------------------------------------------------------
# Adjust paths for the inference rules, according to the current subdir-recursion
#-----------------------------------------------------------------------------
!if "$(DIR)" != ""
src_dir=$(src_dir)\$(DIR)
obj_dir=$(obj_dir)\$(DIR)
!endif

#=============================================================================
# Rules...
#=============================================================================
#-----------------------------------------------------------------------------
# Inference rules for .obj compilation...
# NOTE: The src & obj paths have been updated (see above) to match the subdir,
#       where the tree traversal (recursion) is currently at.
#-----------------------------------------------------------------------------
# Can't direclty add $(patsubst %,.%,$(obj_source_exts)) to .SUFFIXES, as that
# would trigger a syntax error! :-o Well, at least we have a descriptive name:
_compilable_src_exts_=$(patsubst %,.%,$(obj_source_exts))
.SUFFIXES: $(_compilable_src_exts_) .ixx
#-----------------------------------------------------------------------------
{$(src_dir)}.c{$(obj_dir)}.obj::
	$(CC) $(CFLAGS) -Fo$(obj_dir)\ $<

{$(src_dir)}.cpp{$(obj_dir)}.obj::
	$(CXX) $(CFLAGS) $(CXXFLAGS) -Fo$(obj_dir)\ $<

{$(src_dir)}.cxx{$(obj_dir)}.obj::
	$(CXX) $(CFLAGS) $(CXXFLAGS) -Fo$(obj_dir)\ $<

#!!?? This is probably not the way to compile mod. ifcs!...:
#{$(src_dir)}.ixx{$(obj_dir)}.ifc::
#	$(CXX) $(CFLAGS) $(CXXFLAGS) -ifcOutput $(cxx_mod_ifc_dir)\ $<

#-----------------------------------------------------------------------------
# Default target - walk through the src tree dir-by-dir & build each,
#                  plus do an initial and a final wrapping round
#-----------------------------------------------------------------------------
traverse_src_tree: init
	@cmd /v:on /c <<$(out_dir)\treewalk.cmd
	@echo off
	rem !!The make cmd. below fails to run without the extra shell! :-o
	rem !!Also -> #8 why the env. var here can't be called just "make"!... ;)
	set "_make_=cmd /c $(MAKE_CMD)"
	:: echo $(src_dir)
	:: echo !srcroot_fullpath!
	rem Do the root level first (preps + top-level sources)...
	rem (Note: naming a (different) target would avoid inf. recursion!)
        for %%x in ($(obj_source_exts)) do (
		if exist "$(src_dir)\*.%%x" !_make_! /c compiling SRC_EXT_=%%x $(custom_build_options) || if errorlevel 1 exit -1
	)
	rem Scan the rest of the source tree for sources...
	for /f "delims=" %%i in ('dir /s /b /a:d "$(srcroot_fullpath)"') do (
		rem It's *vital* to use a local name here, not dir (==DIR!!!):
		set "_dir_=%%i"
		set "_dir_=!_dir_:$(srcroot_fullpath)\=!"
	        for %%x in ($(obj_source_exts)) do (
			if exist %%i\*.%%x !_make_! /c compiling "DIR=!_dir_!" SRC_EXT_=%%x $(custom_build_options) || if errorlevel 1 exit -1
		)
	)
	!_make_! RECURSED_FOR_FINISHING=1 $(custom_build_options) finish
<<

#-----------------------------------------------------------------------------
# "Tasks" (one-off and type-related high-level (meta/admin) rules)...
#-----------------------------------------------------------------------------
init: mk_main_target_dirs mk_main_lib_rule_inc

compiling: mk_obj_dirs objs

finish: $(BUILD)

mk_main_target_dirs:
# Pre-create the output dirs, as MSVC can't be bothered:
	@if not exist "$(out_dir)" md "$(out_dir)"
	@if not exist "$(lib_dir)" md "$(lib_dir)"
	@if not exist "$(exe_dir)" md "$(exe_dir)"
#!!	@if not exist "$(cxx_mod_ifc_dir)" md "$(cxx_mod_ifc_dir)"

mk_obj_dirs:
# These vary for each subdir, so can't be done just once at init:
	@if not exist "$(obj_dir)" md "$(obj_dir)"

!ifdef SRC_EXT_
objs: $(src_dir)\$(UNITS_PATTERN).$(SRC_EXT_)
	@$(MAKE_CMD) RECURSED_FOR_COMPILING=1 DIR=$(DIR) $(custom_build_options)\
		$(patsubst $(src_dir)\\%,$(obj_dir)\\%, $(subst .$(SRC_EXT_),.obj,$**))
!endif

!if "$(main_lib)" != ""
mainlib_rule_inc=$(out_dir)\mainlib_rule.inc
mk_main_lib_rule_inc:
	@cmd /v:on /c <<$(out_dir)\mklibrule.cmd
	@echo off
	for /r "$(src_dir)\$(lib_src_subdir)" %%o in ($(UNITS_PATTERN).c*) do  (
		set "_o_=%%o"
		set "_o_=!_o_:$(srcroot_fullpath)\=!"
		for %%x in ($(obj_source_exts)) do (
			set "_o_=!_o_:.%%x=.obj!"
		)
		set "objlist=!objlist! $(obj_dir)\!_o_!"
	)
	echo $(main_lib): !objlist! > $(mainlib_rule_inc)
<<
# And this crap is separated here only because echo can't echo TABs:
	@type << >> $(mainlib_rule_inc)
	@echo Creating lib: $$@...
	lib -nologo -out:$$@ $$**
<<
!else
mk_main_lib_rule_inc:
!endif

clean:
# Cleans only the target tree of the current build alternative!
# And no way I'd just let loose a blanket RD /S /Q "$(out_dir)"!...
	@if not "$(abspath $(obj_dir))" == "$(abspath .\$(obj_dir))" echo - ERROR: Invalid object dir path: "$(obj_dir)" && exit -1
# Stop listing all the deleted .obj files despite /q -> cmd /e:off (self-explanatory, right?)
	@if exist "$(obj_dir)\*.obj" cmd /e:off /c del /s /q "$(obj_dir)\*.obj"
# To let the idiotic tools run at least, the dir must exist, so if it was deleted
# in a previous run, we must recreate it just to be able to check and then delete
# it right away again... Otherwise: "The system cannot find the file specified."):
	@if not exist "$(obj_dir)" mkdir "$(obj_dir)"
	@dir "$(obj_dir)" /s /b /a:-d 2>nul || rd /s /q "$(obj_dir)"
# Delete the main targets (lib/exe) separately, as they may be outside the tree:
	@for %f in ($(build)) do @if exist "%f" del "%f"
# Delete some other cruft, too:
	@del "$(out_dir)\*.pdb" "$(out_dir)\*.idb" "$(out_dir)\*.ilk" 2>nul
	@if exist "$(mainlib_rule_inc)" del "$(mainlib_rule_inc)"

clean_all:
	@if not "$(abspath $(out_dir))" == "$(abspath .\$(out_dir))" echo - ERROR: Invalid output dir path: "$(out_dir)" && exit -1
# RD will ask...:
# - But to let the idiotic tools run at least, the dir must exist, so if it was deleted
# in a previous run, we must recreate it just to be able to check and then delete it
# right away again... Otherwise: "The system cannot find the file specified."):
	@if not exist "$(out_dir)" mkdir "$(out_dir)"
	@if not "$(abspath $(out_dir))" == "$(abspath .)" @rd /s "$(out_dir)"
# Delete the libs/exes separately, as they may be off-tree:
	@if exist "$(main_lib)" del "$(main_lib)"
	@if exist "$(main_exe)" del "$(main_exe)"
#!!Still can't do the entire "matrix" tho! :-/ (Behold the freakish triple quotes here! ;) )
	@echo - NOTE: Some build targets may still have been left around, if they are not in """$(out_dir)""".


#-----------------------------------------------------------------------------
# Actual (low-level) one-off build jobs...
#-----------------------------------------------------------------------------
#------------------------
# Build the "main" lib
#------
!if "$(main_lib)" != ""
!ifdef RECURSED_FOR_FINISHING
!include $(mainlib_rule_inc)
!endif
!endif

#------------------------
# Build the "main" exe
#------
!if "$(main_exe)" != ""
$(main_exe): $(obj_dir)\main.obj $(main_lib)
	@echo Creating executable: $@...
	link -nologo $(LINKFLAGS) -out:$@ $(EXT_LIBS) $**
!endif
