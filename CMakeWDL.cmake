set(WDL_OL_PATH "setme" CACHE PATH "WDL-OL framework root directory")

set(CMAKE_XCODE_ATTRIBUTE_CLANG_CXX_LANGUAGE_STANDARD "c++0x")
set(CMAKE_XCODE_ATTRIBUTE_CLANG_CXX_LIBRARY "libc++")

add_compile_definitions($<$<CONFIG:Debug>:_DEBUG>)
add_compile_definitions($<$<CONFIG:Debug>:DEVELOPMENT=1>)
add_compile_definitions($<$<CONFIG:Release>:NDEBUG>)
add_compile_definitions($<$<CONFIG:Release>:RELEASE=1>)

##############################################################################
# VST SDK Base Library
set(VST3SDK_ROOT "${WDL_OL_PATH}/VST3_SDK")
set(VST2SDK_ROOT "${WDL_OL_PATH}/VST_SDK")

file(GLOB vst3sdk_pluginterfaces
    ${VST3SDK_ROOT}/pluginterfaces/base/*.cpp
    ${VST3SDK_ROOT}/pluginterfaces/base/*.h
)
source_group("VST3\\pluginterfaces" FILES ${vst3sdk_pluginterfaces})
file(GLOB vst3sdk_thread
    ${VST3SDK_ROOT}/base/thread/source/*.cpp
    ${VST3SDK_ROOT}/base/thread/include/*.h
)
source_group("VST3\\thread" FILES ${vst3sdk_thread})
file(GLOB vst3sdk_base
    ${VST3SDK_ROOT}/base/source/*.cpp
    ${VST3SDK_ROOT}/base/source/*.h
)
source_group("VST3\\base" FILES ${vst3sdk_base})

add_library(vstsdkbase STATIC ${vst3sdk_pluginterfaces} ${vst3sdk_thread} ${vst3sdk_base})
target_compile_definitions(vstsdkbase PUBLIC $<$<CONFIG:Debug>:_DEBUG>)
target_compile_definitions(vstsdkbase PUBLIC $<$<CONFIG:Debug>:DEVELOPMENT=1>)
target_compile_definitions(vstsdkbase PUBLIC $<$<CONFIG:Release>:NDEBUG>)
target_compile_definitions(vstsdkbase PUBLIC $<$<CONFIG:Release>:RELEASE=1>)
target_include_directories(vstsdkbase PUBLIC ${VST2SDK_ROOT} ${VST3SDK_ROOT})
##############################################################################


##############################################################################
# Lice Library
file(GLOB libpng_sources
    ${WDL_OL_PATH}/WDL/libpng/*.c
    ${WDL_OL_PATH}/WDL/libpng/*.h
)
source_group("libpng" FILES ${libpng_sources})
file(GLOB zlib_sources
    ${WDL_OL_PATH}/WDL/zlib/*.c
    ${WDL_OL_PATH}/WDL/zlib/*.h
)
source_group("zlib" FILES ${zlib_sources})
set(lice_sources
    ${WDL_OL_PATH}/WDL/lice/lice_arc.cpp
    ${WDL_OL_PATH}/WDL/lice/lice_bezier.h
    ${WDL_OL_PATH}/WDL/lice/lice_bmp.cpp
    ${WDL_OL_PATH}/WDL/lice/lice_colorspace.cpp
    ${WDL_OL_PATH}/WDL/lice/lice_combine.h
    ${WDL_OL_PATH}/WDL/lice/lice_extended.h
    ${WDL_OL_PATH}/WDL/lice/lice_image.cpp
    ${WDL_OL_PATH}/WDL/lice/lice_line.cpp
    ${WDL_OL_PATH}/WDL/lice/lice_palette.cpp
    ${WDL_OL_PATH}/WDL/lice/lice_png.cpp
    ${WDL_OL_PATH}/WDL/lice/lice_texgen.cpp
    ${WDL_OL_PATH}/WDL/lice/lice_text.h
    ${WDL_OL_PATH}/WDL/lice/lice_textnew.cpp
    ${WDL_OL_PATH}/WDL/lice/lice.cpp
    ${WDL_OL_PATH}/WDL/lice/lice.h
)
source_group("lice" FILES ${lice_sources})

add_library(lice STATIC ${libpng_sources} ${zlib_sources} ${lice_sources})
target_compile_definitions(lice PUBLIC PNG_USE_PNGVCRD PNG_LIBPNG_SPECIALBUILD __MMX__ PNG_HAVE_MMX_COMBINE_ROW PNG_HAVE_MMX_READ_INTERLACE PNG_HAVE_MMX_READ_FILTER_ROW)
target_compile_definitions(lice PUBLIC $<$<CONFIG:Debug>:PNG_DEBUG>)
target_compile_definitions(lice PUBLIC $<$<CONFIG:Debug>:_DEBUG>)
target_compile_definitions(lice PUBLIC $<$<CONFIG:Debug>:DEVELOPMENT=1>)
target_compile_definitions(lice PUBLIC $<$<CONFIG:Release>:NDEBUG>)
target_compile_definitions(lice PUBLIC $<$<CONFIG:Release>:RELEASE=1>)
##############################################################################


##############################################################################
# WDL Library
set(wdl_vst2_sources
    ${VST2SDK_ROOT}/aeffect.h
    ${VST2SDK_ROOT}/aeffectx.h
)
source_group("WDL\\3rdparty\\VST2" FILES ${wdl_vst2_sources})
file(GLOB wdl_vst3_common
    ${VST3SDK_ROOT}/public.sdk/source/common/*.cpp
    ${VST3SDK_ROOT}/public.sdk/source/common/*.h
)
set(wdl_vst3_main
    ${VST3SDK_ROOT}/public.sdk/source/main/macmain.cpp
    ${VST3SDK_ROOT}/public.sdk/source/main/pluginfactoryvst3.cpp
    ${VST3SDK_ROOT}/public.sdk/source/main/pluginfactoryvst3.h
)
set(wdl_vst3_vst
    ${VST3SDK_ROOT}/public.sdk/source/vst/vstaudioeffect.cpp
    ${VST3SDK_ROOT}/public.sdk/source/vst/vstaudioeffect.h
    ${VST3SDK_ROOT}/public.sdk/source/vst/vstaudioprocessoralgo.h
    ${VST3SDK_ROOT}/public.sdk/source/vst/vstbus.cpp
    ${VST3SDK_ROOT}/public.sdk/source/vst/vstbus.h
    ${VST3SDK_ROOT}/public.sdk/source/vst/vstbypassprocessor.cpp
    ${VST3SDK_ROOT}/public.sdk/source/vst/vstbypassprocessor.h
    ${VST3SDK_ROOT}/public.sdk/source/vst/vstcomponent.cpp
    ${VST3SDK_ROOT}/public.sdk/source/vst/vstcomponent.h
    ${VST3SDK_ROOT}/public.sdk/source/vst/vstcomponentbase.cpp
    ${VST3SDK_ROOT}/public.sdk/source/vst/vstcomponentbase.h
    ${VST3SDK_ROOT}/public.sdk/source/vst/vstinitiids.cpp
    ${VST3SDK_ROOT}/public.sdk/source/vst/vstparameters.cpp
    ${VST3SDK_ROOT}/public.sdk/source/vst/vstparameters.h
    ${VST3SDK_ROOT}/public.sdk/source/vst/vstrepresentation.cpp
    ${VST3SDK_ROOT}/public.sdk/source/vst/vstrepresentation.h
    ${VST3SDK_ROOT}/public.sdk/source/vst/vstsinglecomponenteffect.cpp
    ${VST3SDK_ROOT}/public.sdk/source/vst/vstsinglecomponenteffect.h
    ${VST3SDK_ROOT}/public.sdk/source/vst/vstspeakerarray.h
)
source_group("WDL\\3rdparty\\VST3" FILES ${wdl_vst3_common} ${wdl_vst3_main} ${wdl_vst3_vst})
set(swell_sources
    ${WDL_OL_PATH}/WDL/swell/swell-internal.h
    ${WDL_OL_PATH}/WDL/swell/swell-types.h
    ${WDL_OL_PATH}/WDL/swell/swell-functions.h
    ${WDL_OL_PATH}/WDL/swell/swell-gdi.mm
    ${WDL_OL_PATH}/WDL/swell/swell.h
)
source_group("WDL\\SWELL" FILES ${swell_sources})
set(iplug_au_sources
    ${WDL_OL_PATH}/WDL/IPlug/dfx/dfx-au-utilities.c
    ${WDL_OL_PATH}/WDL/IPlug/dfx/dfx-au-utilities.h
    ${WDL_OL_PATH}/WDL/IPlug/IPlugAU.h
    ${WDL_OL_PATH}/WDL/IPlug/IPlugAU.cpp
    ${WDL_OL_PATH}/WDL/IPlug/IPlugAU.r
    ${WDL_OL_PATH}/WDL/IPlug/IPlugAU_ViewFactory.mm
)
source_group("WDL\\IPlug\\AU" FILES ${iplug_au_sources})
set(iplug_vst2_sources
    ${WDL_OL_PATH}/WDL/IPlug/IPlugVST.h
    ${WDL_OL_PATH}/WDL/IPlug/IPlugVST.cpp
)
source_group("WDL\\IPlug\\VST2" FILES ${iplug_vst2_sources})
set(iplug_vst3_sources
    ${WDL_OL_PATH}/WDL/IPlug/IPlugVST3.h
    ${WDL_OL_PATH}/WDL/IPlug/IPlugVST3.cpp
)
source_group("WDL\\IPlug\\VST3" FILES ${iplug_vst3_sources})
set(iplug_macgui_sources
    ${WDL_OL_PATH}/WDL/IPlug/IGraphicsMac.h
    ${WDL_OL_PATH}/WDL/IPlug/IGraphicsMac.mm
    ${WDL_OL_PATH}/WDL/IPlug/IGraphicsCarbon.h
    ${WDL_OL_PATH}/WDL/IPlug/IGraphicsCarbon.cpp
    ${WDL_OL_PATH}/WDL/IPlug/IGraphicsCocoa.h
    ${WDL_OL_PATH}/WDL/IPlug/IGraphicsCocoa.mm
)
source_group("WDL\\IPlug\\MACGUI" FILES ${iplug_macgui_sources})
set(iplug_sources
    ${WDL_OL_PATH}/WDL/IPlug/IPlugOSDetect.h
    ${WDL_OL_PATH}/WDL/IPlug/IGraphics.h
    ${WDL_OL_PATH}/WDL/IPlug/IGraphics.cpp
    ${WDL_OL_PATH}/WDL/IPlug/IBitmapMonoText.cpp
    ${WDL_OL_PATH}/WDL/IPlug/IBitmapMonoText.h
    ${WDL_OL_PATH}/WDL/IPlug/IPlug_include_in_plug_hdr.h
    ${WDL_OL_PATH}/WDL/IPlug/IPlug_include_in_plug_src.h
    ${WDL_OL_PATH}/WDL/IPlug/IPlugBase.h
    ${WDL_OL_PATH}/WDL/IPlug/IPlugBase.cpp
    ${WDL_OL_PATH}/WDL/IPlug/IPlugStructs.cpp
    ${WDL_OL_PATH}/WDL/IPlug/IPlugStructs.h
    ${WDL_OL_PATH}/WDL/IPlug/IParam.cpp
    ${WDL_OL_PATH}/WDL/IPlug/IParam.h
    ${WDL_OL_PATH}/WDL/IPlug/IControl.h
    ${WDL_OL_PATH}/WDL/IPlug/IControl.cpp
    ${WDL_OL_PATH}/WDL/IPlug/IKeyboardControl.h
    ${WDL_OL_PATH}/WDL/IPlug/Hosts.h
    ${WDL_OL_PATH}/WDL/IPlug/Hosts.cpp
    ${WDL_OL_PATH}/WDL/IPlug/Containers.h
    ${WDL_OL_PATH}/WDL/IPlug/IPopupMenu.h
    ${WDL_OL_PATH}/WDL/IPlug/IPopupMenu.cpp
    ${WDL_OL_PATH}/WDL/IPlug/IPlug_Prefix.pch
    ${WDL_OL_PATH}/WDL/IPlug/IMidiQueue.h
    ${WDL_OL_PATH}/WDL/IPlug/Log.h
    ${WDL_OL_PATH}/WDL/IPlug/Log.cpp
)
source_group("WDL\\IPlug" FILES ${iplug_sources})
set(wdl_sources
    ${WDL_OL_PATH}/WDL/wdlendian.h
    ${WDL_OL_PATH}/WDL/heapbuf.h
    ${WDL_OL_PATH}/WDL/mutex.h
    ${WDL_OL_PATH}/WDL/ptrlist.h
    ${WDL_OL_PATH}/WDL/wdlstring.h
    ${WDL_OL_PATH}/WDL/wdltypes.h
)
source_group("WDL" FILES ${wdl_sources})

set(wdl_au ${swell_sources} ${iplug_au_sources} ${iplug_macgui_sources} ${iplug_sources} ${wdl_sources})
set(wdl_vst2 ${wdl_vst2_sources} ${swell_sources} ${iplug_vst2_sources} ${iplug_macgui_sources} ${iplug_sources} ${wdl_sources})
set(wdl_vst3 ${wdl_vst3_common} ${wdl_vst3_main} ${wdl_vst3_vst} ${swell_sources} ${iplug_vst3_sources} ${iplug_macgui_sources} ${iplug_sources} ${wdl_sources})
##############################################################################

