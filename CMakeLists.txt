project("WaveSabre")

cmake_minimum_required(VERSION 3.11)
set_property(GLOBAL PROPERTY USE_FOLDERS ON)

if(MSVC)
##############################################################################
# CMake used to build WaveSabre for Windows

if(MSVC)
	# disable exceptions globally (will be added back for VSTs)
	string(REPLACE "/EHsc" "" CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS})
endif()

# shared code
add_subdirectory(WaveSabreCore)
add_subdirectory(WaveSabrePlayerLib)
add_subdirectory(WaveSabreVstLib)

# binaries
add_subdirectory(Tests/PlayerTest)
add_subdirectory(WaveSabreStandAlonePlayer)
add_subdirectory(Vsts)

endif()



if(APPLE)
##############################################################################
# CMake used to build WaveSabre for MacOS
#
# Note: It can only output vst in 64bit version!
#
# IMPORTANT:
#
# 1- To compile on latest XCode, since QuickTime is completely deprecated,
# you need to manually edit the file: "Vst3.x/vstgui.sf/vstgui/vstgui.cpp"
# to remove a reference to it.
#   Go to the line 220 and:
#     comment: `//#include <QuickTime/QuickTime.h>`
#     and add: `#include <Carbon/Carbon.h>`
#
# 2- You should retrieve the "gm.dls" file from a Windows and place it in the
# "Data/macOS" directory. You may look at "C:/Windows/System32/drivers/gm.dsl"
#
# 3- If you wish to rebuild libsndfile and libsamplerate, you should use the
# following command to make the dynamic libraries loadable once embedded.
# `install_name_tool -id @loader_path/libsndfile.dylib libsndfile.dylib`
# `install_name_tool -id @loader_path/libsamplerate.dylib libsamplerate.dylib`
# You can then check the changes using `otool -D` and `otool -L`
# The libs can then reside close to the executable in the MacOS folder of the
# bundle.

##############################################################################
# Includes
include(CMakeParseArguments)

##############################################################################
# CMake Policies
if(POLICY CMP0054)
	cmake_policy(SET CMP0054 NEW)
endif()

##############################################################################
# Global Settings
set(CMAKE_BUILD_TYPE "Debug" CACHE STRING "Build type")
# Setup output directories
set(CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/dist")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")
# macOS defaults
if(NOT DEFINED ENV{MACOSX_DEPLOYMENT_TARGET})
	set(CMAKE_OSX_DEPLOYMENT_TARGET "10.8" CACHE STRING "macOS deployment target")
endif()
if(NOT DEFINED ENV{SDKROOT})
	execute_process(COMMAND xcrun --sdk macosx --show-sdk-path OUTPUT_VARIABLE CMAKE_OSX_SYSROOT OUTPUT_STRIP_TRAILING_WHITESPACE)
endif()
# Force 64bit architecture (will force use of Cocoa too for vstgui 2.x)
set(CMAKE_OSX_ARCHITECTURES x86_64)
# Generation Settings
set(CMAKE_CONFIGURATION_TYPES "Debug;Release")
set(CMAKE_EXPORT_COMPILE_COMMANDS ON CACHE STRING "Generate compile commands" FORCE)
set(CMAKE_SKIP_ASSEMBLY_SOURCE_RULES ON)
set(CMAKE_SKIP_INSTALL_RULES ON)
set(CMAKE_SKIP_PREPROCESSED_SOURCE_RULES ON)
set_property(GLOBAL PROPERTY PREDEFINED_TARGETS_FOLDER Predefined)
add_compile_options($<$<CONFIG:Debug>:-DDEVELOPMENT=1>)
add_compile_options($<$<CONFIG:Release>:-DRELEASE=1>)

##############################################################################
# Process the Info.plist to bundle
function(lgcm_process_plist target)
	cmake_parse_arguments(ARG "PREPROCESS" "INFOPLIST" "PREPROCESSOR_FLAGS" ${ARGN})
	if(ARG_UNPARSED_ARGUMENTS)
		message(FATAL_ERROR "The following parameters are unrecognized: ${ARG_UNPARSED_ARGUMENTS}")
	endif()

	if(ARG_INFOPLIST)
		set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_INFOPLIST_FILE "${ARG_INFOPLIST}")
		if(ARG_PREPROCESS)
			set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_INFOPLIST_PREPROCESS "YES")
		endif()
		if(ARG_PREPROCESSOR_FLAGS)
			set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_INFOPLIST_OTHER_PREPROCESSOR_FLAGS "${ARG_PREPROCESSOR_FLAGS}")
		endif()
	endif()
endfunction()

##############################################################################
# Add a binary ressource to the bundle
function(lgcm_add_vst_resource target input_file)
	# Adding the bundle resources to the target sources creates a warning, see https://cmake.org/Bug/view.php?id=15272
	target_sources(${target} PRIVATE ${input_file})
	set_source_files_properties(${input_file} PROPERTIES MACOSX_PACKAGE_LOCATION Resources)
endfunction()

##############################################################################
# Add a binary ressource to the bundle
function(lgcm_add_vst_dylib target dylib)
	target_sources(${target} PRIVATE ${dylib})
	set_source_files_properties(${dylib} PROPERTIES MACOSX_PACKAGE_LOCATION MacOS)
	target_link_libraries(${target} PRIVATE ${dylib})
endfunction()

##############################################################################
# VST Plugin Template
function(lgcm_add_vstplugin target sdkroot)
	set(sources ${ARGN})

	add_library(${target} MODULE ${sources})

	set_target_properties(${target} PROPERTIES BUNDLE TRUE)
	set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_GENERATE_PKGINFO_FILE "YES")
	set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_WRAPPER_EXTENSION "vst")
	set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_EXPORTED_SYMBOLS_FILE "Data/macOS/macexport.exp")

	target_link_libraries(${target} PRIVATE "-framework CoreFoundation -framework Cocoa -framework Carbon")
endfunction()

function(lgcm_vstplugin target sdkroot wscore wsvstlib wsvstroot)
	set(sources
		${wsvstroot}/${target}/${target}Editor.cpp
		${wsvstroot}/${target}/${target}Editor.h
		${wsvstroot}/${target}/${target}Vst.cpp
		${wsvstroot}/${target}/${target}Vst.h
		${ARGN}
	)

	lgcm_add_vstplugin(${target} ${sdkroot} ${sources})
	
	target_include_directories(${target} PUBLIC ${wsvstroot}/${target} ${wscore}/include ${wsvstlib}/include ${sdkroot} ${sdkroot}/vstgui.sf/zlib ${sdkroot}/vstgui.sf/libpng ${sdkroot}/public.sdk/source/vst2.x)

	target_link_libraries(${target} PRIVATE WaveSabreVstLib WaveSabreCore)

	lgcm_add_vst_resource(${target} "Data/background.png")
	lgcm_add_vst_resource(${target} "Data/knob1.png")
	lgcm_add_vst_resource(${target} "Data/optionmenu-pressed.png")
	lgcm_add_vst_resource(${target} "Data/optionmenu-unpressed.png")
	lgcm_add_vst_resource(${target} "Data/tinybutton.png")

	lgcm_process_plist(${target} INFOPLIST "${CMAKE_CURRENT_LIST_DIR}/Data/macOS/Info.plist" PREPROCESS)
endfunction()
##############################################################################

##############################################################################
# libsndfile
#set(BUILD_STATIC_LIBS OFF CACHE BOOL "Build static libraries")
#set(BUILD_SHARED_LIBS ON CACHE BOOL "Build shared libraries")
#set(BUILD_PROGRAMS OFF CACHE BOOL "Build programs")
#set(BUILD_EXAMPLES OFF CACHE BOOL "Build examples")
#set(BUILD_TESTING OFF CACHE BOOL "Build tests")
#set(ENABLE_CPACK OFF CACHE BOOL "Enable CPack support")
#set(DISABLE_EXTERNAL_LIBS ON CACHE BOOL "Disable use of FLAC, Ogg and Vorbis")
#set(ENABLE_EXPERIMENTAL OFF CACHE BOOL "Enable experimental code")
#set(DISABLE_CPU_CLIP OFF CACHE BOOL "Disable tricky cpu specific clipper")
#set(ENABLE_BOW_DOCS OFF CACHE BOOL "Enable black-on-white html docs")
#set(ENABLE_PACKAGE_CONFIG OFF CACHE BOOL "Generate and install package config file")
#set(BUILD_REGTEST OFF CACHE BOOL "Build regtest")
#add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/libsndfile)

##############################################################################
# WaveSabre
set(CMAKE_XCODE_ATTRIBUTE_CLANG_CXX_LANGUAGE_STANDARD "c++14")
set(CMAKE_XCODE_ATTRIBUTE_CLANG_CXX_LIBRARY "libc++")

set(ROOT "${CMAKE_CURRENT_SOURCE_DIR}")

set(VSTSDK_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/Vst3.x")

set(SDK_IDE_LIBS_FOLDER FOLDER "Libraries")
set(SDK_IDE_PLUGIN_EXAMPLES_FOLDER FOLDER "PlugInExamples")
set(SDK_IDE_HOSTING_EXAMPLES_FOLDER FOLDER "HostingExamples")

##############################################################################
# libsndfile
set(libsndfile_includes
	${CMAKE_CURRENT_SOURCE_DIR}/Data/macOS/libsndfile
)
set(libsndfile_lib
	${CMAKE_CURRENT_SOURCE_DIR}/Data/macOS/libsndfile/libsndfile.dylib
)
function(lgcm_add_vst_libsndfile target)
	lgcm_add_vst_dylib(${target} ${CMAKE_CURRENT_SOURCE_DIR}/Data/macOS/libsndfile/libsndfile.dylib)
endfunction()

##############################################################################
# WaveSabreCore
set(wscore_root "${CMAKE_CURRENT_SOURCE_DIR}/WaveSabreCore")
set(wscore_includes
	${wscore_root}/include/WaveSabreCore.h
	${wscore_root}/include/WaveSabreCore/AllPass.h
	${wscore_root}/include/WaveSabreCore/AllPassDelay.h
	${wscore_root}/include/WaveSabreCore/Comb.h
	${wscore_root}/include/WaveSabreCore/DelayBuffer.h
	${wscore_root}/include/WaveSabreCore/Device.h
	${wscore_root}/include/WaveSabreCore/Devices.h
	${wscore_root}/include/WaveSabreCore/Envelope.h
	${wscore_root}/include/WaveSabreCore/BiquadFilter.h
	${wscore_root}/include/WaveSabreCore/GmDls.h
	${wscore_root}/include/WaveSabreCore/Helpers.h
	${wscore_root}/include/WaveSabreCore/MacOSHelpers.h
	${wscore_root}/include/WaveSabreCore/ResampleBuffer.h
	${wscore_root}/include/WaveSabreCore/SamplePlayer.h
	${wscore_root}/include/WaveSabreCore/StateVariableFilter.h
	${wscore_root}/include/WaveSabreCore/SynthDevice.h
    ${wscore_root}/include/WaveSabreCore/MxcsrFlagGuard.h
)
source_group("WaveSabreCore" FILES ${wscore_includes})
set(wscore_devices_includes
	${wscore_root}/include/WaveSabreCore/Scissor.h
	${wscore_root}/include/WaveSabreCore/Falcon.h
	${wscore_root}/include/WaveSabreCore/Adultery.h
	${wscore_root}/include/WaveSabreCore/Cathedral.h
	${wscore_root}/include/WaveSabreCore/Chamber.h
	${wscore_root}/include/WaveSabreCore/Crusher.h
	${wscore_root}/include/WaveSabreCore/Echo.h
	${wscore_root}/include/WaveSabreCore/Leveller.h
	${wscore_root}/include/WaveSabreCore/Slaughter.h
	${wscore_root}/include/WaveSabreCore/Smasher.h
	${wscore_root}/include/WaveSabreCore/Specimen.h
	${wscore_root}/include/WaveSabreCore/Thunder.h
	${wscore_root}/include/WaveSabreCore/Twister.h
)
source_group("WaveSabreCore\\Devices" FILES ${wscore_devices_includes})
set(wscore_all_includes ${wscore_includes} ${wscore_devices_includes})

set(wscore_srcs
	${wscore_root}/src/AllPass.cpp
	${wscore_root}/src/AllPassDelay.cpp
	${wscore_root}/src/Comb.cpp
	${wscore_root}/src/DelayBuffer.cpp
	${wscore_root}/src/Device.cpp
	${wscore_root}/src/Envelope.cpp
	${wscore_root}/src/BiquadFilter.cpp
	${wscore_root}/src/GmDls.cpp
	${wscore_root}/src/Helpers.cpp
	${wscore_root}/src/MacOSHelpers.cpp
	${wscore_root}/src/ResampleBuffer.cpp
	${wscore_root}/src/SamplePlayer.cpp
	${wscore_root}/src/StateVariableFilter.cpp
	${wscore_root}/src/SynthDevice.cpp
    ${wscore_root}/src/MxcsrFlagGuard.cpp
)
source_group("WaveSabreCore" FILES ${wscore_srcs})
set(wscore_devices_srcs
	${wscore_root}/src/Scissor.cpp
	${wscore_root}/src/Falcon.cpp
	${wscore_root}/src/Adultery.cpp
	${wscore_root}/src/Cathedral.cpp
	${wscore_root}/src/Chamber.cpp
	${wscore_root}/src/Crusher.cpp
	${wscore_root}/src/Echo.cpp
	${wscore_root}/src/Leveller.cpp
	${wscore_root}/src/Slaughter.cpp
	${wscore_root}/src/Smasher.cpp
	${wscore_root}/src/Specimen.cpp
	${wscore_root}/src/Thunder.cpp
	${wscore_root}/src/Twister.cpp
)
source_group("WaveSabreCore\\Devices" FILES ${wscore_devices_srcs})
set(wscore_all_srcs ${wscore_srcs} ${wscore_devices_srcs})

add_library(WaveSabreCore STATIC ${wscore_all_srcs} ${wscore_all_includes})
target_compile_definitions(WaveSabreCore PUBLIC -DLGCM_MAC)
target_include_directories(WaveSabreCore PUBLIC ${wscore_root}/include ${libsndfile_includes})
target_link_libraries(WaveSabreCore ${libsndfile_lib})

##############################################################################
# WaveSabreVstLib
set(wsvstlib_root "${CMAKE_CURRENT_SOURCE_DIR}/WaveSabreVstLib")
set(wsvstlib_includes
	${wsvstlib_root}/include/WaveSabreVstLib.h
	${wsvstlib_root}/include/WaveSabreVstLib/Common.h
	${wsvstlib_root}/include/WaveSabreVstLib/ImageManager.h
	${wsvstlib_root}/include/WaveSabreVstLib/NoTextCOptionMenu.h
	${wsvstlib_root}/include/WaveSabreVstLib/VstEditor.h
	${wsvstlib_root}/include/WaveSabreVstLib/VstPlug.h
)
source_group("WaveSabreVstLib" FILES ${wsvstlib_includes})
set(wsvstlib_pluginterfaces_includes
	${VSTSDK_ROOT}/pluginterfaces/vst2.x/aeffect.h
	${VSTSDK_ROOT}/pluginterfaces/vst2.x/aeffectx.h
	${VSTSDK_ROOT}/pluginterfaces/vst2.x/vstfxstore.h
)
source_group("VST3\\pluginterfaces" FILES ${wsvstlib_pluginterfaces_includes})
set(wsvstlib_publicsdk_includes
	${VSTSDK_ROOT}/public.sdk/source/vst2.x/aeffeditor.h
	${VSTSDK_ROOT}/public.sdk/source/vst2.x/audioeffect.h
	${VSTSDK_ROOT}/public.sdk/source/vst2.x/audioeffectx.h
)
source_group("VST3\\public.sdk" FILES ${wsvstlib_publicsdk_includes})
set(wsvstlib_vstgui_includes
	${VSTSDK_ROOT}/vstgui.sf/vstgui/aeffguieditor.h
	${VSTSDK_ROOT}/vstgui.sf/vstgui/cfileselector.h
	${VSTSDK_ROOT}/vstgui.sf/vstgui/vstcontrols.h
	${VSTSDK_ROOT}/vstgui.sf/vstgui/vstgui.h
	${VSTSDK_ROOT}/vstgui.sf/vstgui/vstguidebug.h
	${VSTSDK_ROOT}/vstgui.sf/vstgui/vstkeycode.h
	${VSTSDK_ROOT}/vstgui.sf/vstgui/cvstguitimer.h
	${VSTSDK_ROOT}/vstgui.sf/vstgui/cocoasupport.h
)
source_group("VST3\\vstgui" FILES ${wsvstlib_vstgui_includes})
set(wsvstlib_libpng_includes
	${VSTSDK_ROOT}/vstgui.sf/libpng/png.h
	${VSTSDK_ROOT}/vstgui.sf/libpng/pngconf.h
)
source_group("VST3\\libpng" FILES ${wsvstlib_libpng_includes})
set(wsvstlib_zlib_includes
	${VSTSDK_ROOT}/vstgui.sf/zlib/crc32.h
	${VSTSDK_ROOT}/vstgui.sf/zlib/deflate.h
	${VSTSDK_ROOT}/vstgui.sf/zlib/inffast.h
	${VSTSDK_ROOT}/vstgui.sf/zlib/inffixed.h
	${VSTSDK_ROOT}/vstgui.sf/zlib/inflate.h
	${VSTSDK_ROOT}/vstgui.sf/zlib/inftrees.h
	${VSTSDK_ROOT}/vstgui.sf/zlib/trees.h
	${VSTSDK_ROOT}/vstgui.sf/zlib/zconf.h
	${VSTSDK_ROOT}/vstgui.sf/zlib/zlib.h
	${VSTSDK_ROOT}/vstgui.sf/zlib/zutil.h
)
source_group("VST3\\zlib" FILES ${wsvstlib_zlib_includes})
set(wsvstlib_all_includes ${wsvstlib_includes} ${wsvstlib_pluginterfaces_includes} ${wsvstlib_publicsdk_includes} ${wsvstlib_vstgui_includes} ${wsvstlib_libpng_includes} ${wsvstlib_zlib_includes})

set(wsvstlib_srcs
	${wsvstlib_root}/src/ImageManager.cpp
	${wsvstlib_root}/src/NoTextCOptionMenu.cpp
	${wsvstlib_root}/src/VstEditor.cpp
	${wsvstlib_root}/src/VstPlug.cpp
)
source_group("WaveSabreVstLib" FILES ${wsvstlib_srcs})
set(wsvstlib_publicsdk_srcs
	${VSTSDK_ROOT}/public.sdk/source/vst2.x/audioeffect.cpp
	${VSTSDK_ROOT}/public.sdk/source/vst2.x/audioeffectx.cpp
	${VSTSDK_ROOT}/public.sdk/source/vst2.x/vstplugmain.cpp
)
source_group("VST3\\public.sdk" FILES ${wsvstlib_publicsdk_srcs})
set(wsvstlib_vstgui_srcs
	${VSTSDK_ROOT}/vstgui.sf/vstgui/aeffguieditor.cpp
	${VSTSDK_ROOT}/vstgui.sf/vstgui/cfileselector.cpp
	${VSTSDK_ROOT}/vstgui.sf/vstgui/vstcontrols.cpp
	${VSTSDK_ROOT}/vstgui.sf/vstgui/vstgui.cpp
	${VSTSDK_ROOT}/vstgui.sf/vstgui/vstguidebug.cpp
	${VSTSDK_ROOT}/vstgui.sf/vstgui/cvstguitimer.cpp
	${VSTSDK_ROOT}/vstgui.sf/vstgui/cocoasupport.mm
)
source_group("VST3\\vstgui" FILES ${wsvstlib_vstgui_srcs})
set(wsvstlib_libpng_srcs
	${VSTSDK_ROOT}/vstgui.sf/libpng/png.c
	${VSTSDK_ROOT}/vstgui.sf/libpng/pngerror.c
	${VSTSDK_ROOT}/vstgui.sf/libpng/pnggccrd.c
	${VSTSDK_ROOT}/vstgui.sf/libpng/pngget.c
	${VSTSDK_ROOT}/vstgui.sf/libpng/pngmem.c
	${VSTSDK_ROOT}/vstgui.sf/libpng/pngpread.c
	${VSTSDK_ROOT}/vstgui.sf/libpng/pngread.c
	${VSTSDK_ROOT}/vstgui.sf/libpng/pngrio.c
	${VSTSDK_ROOT}/vstgui.sf/libpng/pngrtran.c
	${VSTSDK_ROOT}/vstgui.sf/libpng/pngrutil.c
	${VSTSDK_ROOT}/vstgui.sf/libpng/pngset.c
	${VSTSDK_ROOT}/vstgui.sf/libpng/pngtrans.c
	${VSTSDK_ROOT}/vstgui.sf/libpng/pngvcrd.c
	${VSTSDK_ROOT}/vstgui.sf/libpng/pngwio.c
	${VSTSDK_ROOT}/vstgui.sf/libpng/pngwrite.c
	${VSTSDK_ROOT}/vstgui.sf/libpng/pngwtran.c
	${VSTSDK_ROOT}/vstgui.sf/libpng/pngwutil.c
)
source_group("VST3\\libpng" FILES ${wsvstlib_libpng_srcs})
set(wsvstlib_zlib_srcs
	${VSTSDK_ROOT}/vstgui.sf/zlib/adler32.c
	${VSTSDK_ROOT}/vstgui.sf/zlib/compress.c
	${VSTSDK_ROOT}/vstgui.sf/zlib/crc32.c
	${VSTSDK_ROOT}/vstgui.sf/zlib/deflate.c
	${VSTSDK_ROOT}/vstgui.sf/zlib/gzio.c
	${VSTSDK_ROOT}/vstgui.sf/zlib/infback.c
	${VSTSDK_ROOT}/vstgui.sf/zlib/inffast.c
	${VSTSDK_ROOT}/vstgui.sf/zlib/inflate.c
	${VSTSDK_ROOT}/vstgui.sf/zlib/inftrees.c
	${VSTSDK_ROOT}/vstgui.sf/zlib/minigzip.c
	${VSTSDK_ROOT}/vstgui.sf/zlib/trees.c
	${VSTSDK_ROOT}/vstgui.sf/zlib/uncompr.c
	${VSTSDK_ROOT}/vstgui.sf/zlib/zutil.c
)
source_group("VST3\\zlib" FILES ${wsvstlib_zlib_srcs})
set(wsvstlib_all_srcs ${wsvstlib_srcs} ${wsvstlib_publicsdk_srcs} ${wsvstlib_vstgui_srcs} ${wsvstlib_libpng_srcs} ${wsvstlib_zlib_srcs})

add_library(WaveSabreVstLib STATIC ${wsvstlib_all_srcs} ${wsvstlib_all_includes})
target_compile_definitions(WaveSabreVstLib PUBLIC -DLGCM_MAC -DUSE_LIBPNG)
target_include_directories(WaveSabreVstLib PUBLIC ${wsvstlib_root}/include ${wscore_root}/include ${libsndfile_includes} ${VSTSDK_ROOT} ${VSTSDK_ROOT}/vstgui.sf/zlib ${VSTSDK_ROOT}/vstgui.sf/libpng ${VSTSDK_ROOT}/public.sdk/source/vst2.x)

##############################################################################
# WaveSabre VSTs
set(wsvst_root "${CMAKE_CURRENT_SOURCE_DIR}/Vsts")

include(CMakeWDL.cmake)
include(CMakeWDLVST.cmake)

lgcm_vstplugin(Adultery ${VSTSDK_ROOT} ${wscore_root} ${wsvstlib_root} ${wsvst_root})
lgcm_add_vst_resource(Adultery "Data/macOS/gm.dls")
lgcm_vstplugin(Cathedral ${VSTSDK_ROOT} ${wscore_root} ${wsvstlib_root} ${wsvst_root})
lgcm_vstplugin(Chamber ${VSTSDK_ROOT} ${wscore_root} ${wsvstlib_root} ${wsvst_root})
#lgcm_vstplugin(Crusher ${VSTSDK_ROOT} ${wscore_root} ${wsvstlib_root} ${wsvst_root})
alk_vst2plugin(Crusher)
#lgcm_vstplugin(Echo ${VSTSDK_ROOT} ${wscore_root} ${wsvstlib_root} ${wsvst_root})
alk_vst2plugin(Echo)
lgcm_vstplugin(Falcon ${VSTSDK_ROOT} ${wscore_root} ${wsvstlib_root} ${wsvst_root})
lgcm_vstplugin(Leveller ${VSTSDK_ROOT} ${wscore_root} ${wsvstlib_root} ${wsvst_root})
lgcm_vstplugin(Scissor ${VSTSDK_ROOT} ${wscore_root} ${wsvstlib_root} ${wsvst_root})
lgcm_vstplugin(Slaughter ${VSTSDK_ROOT} ${wscore_root} ${wsvstlib_root} ${wsvst_root})
lgcm_vstplugin(Smasher ${VSTSDK_ROOT} ${wscore_root} ${wsvstlib_root} ${wsvst_root})
lgcm_vstplugin(Specimen ${VSTSDK_ROOT} ${wscore_root} ${wsvstlib_root} ${wsvst_root})
lgcm_add_vst_libsndfile(Specimen)
lgcm_vstplugin(Thunder ${VSTSDK_ROOT} ${wscore_root} ${wsvstlib_root} ${wsvst_root})
lgcm_add_vst_libsndfile(Thunder)
lgcm_vstplugin(Twister ${VSTSDK_ROOT} ${wscore_root} ${wsvstlib_root} ${wsvst_root})

endif()
