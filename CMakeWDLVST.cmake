##############################################################################
# Add a ressource to the bundle
function(alk_add_resource target input_file)
    target_sources(${target} PRIVATE ${input_file})
    set_source_files_properties(${input_file} PROPERTIES MACOSX_PACKAGE_LOCATION Resources)
endfunction()

##############################################################################
# Process the Info.plist to bundle
function(alk_process_plist target)
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
# VST Plugin Template
function(alk_vst2plugin target)
    set(multiValueArgs SOURCES RESOURCES)
    cmake_parse_arguments(VST2 "" "" "${multiValueArgs}" ${ARGN})

    file(GLOB vst_sources
        ${CMAKE_CURRENT_LIST_DIR}/VstsWDL/${target}/*.cpp
        ${CMAKE_CURRENT_LIST_DIR}/VstsWDL/${target}/*.h
        ${CMAKE_CURRENT_LIST_DIR}/VstsWDL/${target}/resources/mac/*.plist
    )
    source_group(${target} FILES ${vst_sources})
    file(GLOB vst_resources
        ${CMAKE_CURRENT_LIST_DIR}/VstsWDL/${target}/resources/*.png
    )
    source_group("Resources" FILES ${vst_resources})
    file(GLOB vst_wsiplug
        ${CMAKE_CURRENT_LIST_DIR}/VstsWDL/WSiPlug.cpp
        ${CMAKE_CURRENT_LIST_DIR}/VstsWDL/WSiPlug.h
    )
    source_group("WSiPlug" FILES ${vst_wsiplug})

    add_library(${target} MODULE ${vst_sources} ${wdl_vst2} ${vst_wsiplug})

    target_compile_definitions(${target} PUBLIC VST_API)

    set_target_properties(${target} PROPERTIES BUNDLE TRUE)
    set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_GENERATE_PKGINFO_FILE "YES")
    set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_WRAPPER_EXTENSION "vst")

    target_link_libraries(${target} PRIVATE "-framework CoreFoundation -framework Cocoa -framework Carbon")

    target_include_directories(${target} PUBLIC ${CMAKE_CURRENT_LIST_DIR}/VstsWDL/${target} ${wscore}/include ${VST2SDK_ROOT} ${WDL_OL_PATH} ${WDL_OL_PATH}/WDL/IPlug)

    target_link_libraries(${target} PRIVATE WaveSabreCore lice)

    target_compile_definitions(${target} PUBLIC $<$<CONFIG:Debug>:_DEBUG>)
    target_compile_definitions(${target} PUBLIC $<$<CONFIG:Debug>:DEVELOPMENT=1>)
    target_compile_definitions(${target} PUBLIC $<$<CONFIG:Release>:NDEBUG>)
    target_compile_definitions(${target} PUBLIC $<$<CONFIG:Release>:RELEASE=1>)

    foreach(item ${vst_resources})
        alk_add_resource(${target} ${item})
    endforeach()

    alk_process_plist(${target} INFOPLIST "${CMAKE_CURRENT_LIST_DIR}/VstsWDL/${target}/resources/mac/${target}-VST2-Info.plist" PREPROCESS)
endfunction()

function(alk_vst3plugin target)
    file(GLOB vst_sources
        ${CMAKE_CURRENT_LIST_DIR}/VstsWDL/${target}/*.cpp
        ${CMAKE_CURRENT_LIST_DIR}/VstsWDL/${target}/*.h
        ${CMAKE_CURRENT_LIST_DIR}/VstsWDL/${target}/resources/mac/*.plist
    )
    source_group(${target} FILES ${vst_sources})
    file(GLOB vst_resources
        ${CMAKE_CURRENT_LIST_DIR}/VstsWDL/${target}/resources/*.png
    )
    source_group("Resources" FILES ${vst_resources})
    file(GLOB vst_wsiplug
        ${CMAKE_CURRENT_LIST_DIR}/VstsWDL/WSiPlug.cpp
        ${CMAKE_CURRENT_LIST_DIR}/VstsWDL/WSiPlug.h
    )
    source_group("WSiPlug" FILES ${vst_wsiplug})

    add_library(${target} MODULE ${vst_sources} ${wdl_vst3} ${vst_wsiplug})

    target_compile_definitions(${target} PUBLIC VST3_API)

    set_target_properties(${target} PROPERTIES BUNDLE TRUE)
    set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_GENERATE_PKGINFO_FILE "YES")
    set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_WRAPPER_EXTENSION "vst3")

    target_link_libraries(${target} PRIVATE "-framework CoreFoundation -framework Cocoa -framework Carbon")

    target_include_directories(${target} PUBLIC ${CMAKE_CURRENT_LIST_DIR}/VstsWDL/${target} ${wscore}/include ${VST3SDK_ROOT} ${WDL_OL_PATH} ${WDL_OL_PATH}/WDL/IPlug)

    target_link_libraries(${target} PRIVATE WaveSabreCore vstsdkbase lice)

    target_compile_definitions(${target} PUBLIC $<$<CONFIG:Debug>:_DEBUG>)
    target_compile_definitions(${target} PUBLIC $<$<CONFIG:Debug>:DEVELOPMENT=1>)
    target_compile_definitions(${target} PUBLIC $<$<CONFIG:Release>:NDEBUG>)
    target_compile_definitions(${target} PUBLIC $<$<CONFIG:Release>:RELEASE=1>)

    foreach(item ${vst_resources})
        alk_add_resource(${target} ${item})
    endforeach()

    alk_process_plist(${target} INFOPLIST "${CMAKE_CURRENT_LIST_DIR}/VstsWDL/${target}/resources/mac/${target}-VST3-Info.plist" PREPROCESS)
endfunction()
##############################################################################
