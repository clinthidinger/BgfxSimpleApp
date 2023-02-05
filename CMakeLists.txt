cmake_minimum_required(VERSION 3.0 FATAL_ERROR)

PROJECT(bgfx-simple-app LANGUAGES CXX C)

option(ENABLE_IMGUI "Enable DearImGui" on)
option(ENABLE_NANOVG "Enable nanoVG" on)
set(BGFX_DIR ${CMAKE_SOURCE_DIR}/../../npainter/ThirdParty/bgfx)
set(BIMG_DIR ${CMAKE_SOURCE_DIR}/../../npainter/ThirdParty/bimg)
set(BX_DIR ${CMAKE_SOURCE_DIR}/../../npainter/ThirdParty/bx)
get_filename_component(BGFX_LIB_DIR ${BGFX_DIR}/.build/win64_vs2022/bin ABSOLUTE)
get_filename_component(SHADERC ${BGFX_DIR}/.build/win64_vs2022/bin/shaderc$<$<CONFIG:Debug>:Debug>$<$<CONFIG:Release>:Release>.exe ABSOLUTE)
set(SHADER_DIR ${CMAKE_CURRENT_SOURCE_DIR}/shaders)

set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS} -std=c++17)
set(BX_CONFIG_DEBUG $<CONFIG:Debug>)

if(WIN32)
	add_compile_options( /wd4201 /wd4324 /Ob2 /Zc:__cplusplus)
	# This is a hack.  Shouldn't have to do this if setting MSVC_RUNTIME_LIBRARY below worked.
	string(REPLACE "MDd" "MTd" CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG}")
	string(REPLACE "MD" "MT" CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE}")
	string(REPLACE "MDd" "MTd" CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG}")
	string(REPLACE "MD" "MT" CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE}")
endif(WIN32)

if(ENABLE_IMGUI)
	set(IMGUI_SRC
		${BGFX_DIR}/3rdparty/dear-imgui/widgets/color_picker.h
		${BGFX_DIR}/3rdparty/dear-imgui/widgets/color_picker.inl
		${BGFX_DIR}/3rdparty/dear-imgui/widgets/color_wheel.h
		${BGFX_DIR}/3rdparty/dear-imgui/widgets/color_wheel.inl
		${BGFX_DIR}/3rdparty/dear-imgui/widgets/dock.h
		${BGFX_DIR}/3rdparty/dear-imgui/widgets/dock.inl
		${BGFX_DIR}/3rdparty/dear-imgui/widgets/file_list.h
		${BGFX_DIR}/3rdparty/dear-imgui/widgets/file_list.inl
		${BGFX_DIR}/3rdparty/dear-imgui/widgets/gizmo.h
		${BGFX_DIR}/3rdparty/dear-imgui/widgets/gizmo.inl
		${BGFX_DIR}/3rdparty/dear-imgui/widgets/markdown.h
		${BGFX_DIR}/3rdparty/dear-imgui/widgets/markdown.inl
		${BGFX_DIR}/3rdparty/dear-imgui/widgets/range_slider.h
		${BGFX_DIR}/3rdparty/dear-imgui/widgets/range_slider.inl
		${BGFX_DIR}/3rdparty/dear-imgui/imconfig.h
		${BGFX_DIR}/3rdparty/dear-imgui/imgui.cpp
		${BGFX_DIR}/3rdparty/dear-imgui/imgui.h
		${BGFX_DIR}/3rdparty/dear-imgui/imgui_demo.cpp
		${BGFX_DIR}/3rdparty/dear-imgui/imgui_draw.cpp
		${BGFX_DIR}/3rdparty/dear-imgui/imgui_internal.h
		${BGFX_DIR}/3rdparty/dear-imgui/imgui_tables.cpp
		${BGFX_DIR}/3rdparty/dear-imgui/imgui_user.h
		${BGFX_DIR}/3rdparty/dear-imgui/imgui_user.inl
		${BGFX_DIR}/3rdparty/dear-imgui/imgui_widgets.cpp
		${BGFX_DIR}/3rdparty/dear-imgui/imstb_rectpack.h
		${BGFX_DIR}/3rdparty/dear-imgui/imstb_textedit.h
		${BGFX_DIR}/3rdparty/dear-imgui/imstb_truetype.h
	)
	set(BGFX_DEBUGDRAW_SRC
		${BGFX_DIR}/examples/common/debugdraw/debugdraw.cpp
		${BGFX_DIR}/examples/common/debugdraw/debugdraw.h
		${BGFX_DIR}/examples/common/debugdraw/fs_debugdraw_fill.bin.h          
		${BGFX_DIR}/examples/common/debugdraw/fs_debugdraw_fill.sc             
		${BGFX_DIR}/examples/common/debugdraw/fs_debugdraw_fill_lit.bin.h      
		${BGFX_DIR}/examples/common/debugdraw/fs_debugdraw_fill_lit.sc         
		${BGFX_DIR}/examples/common/debugdraw/fs_debugdraw_fill_texture.bin.h  
		${BGFX_DIR}/examples/common/debugdraw/fs_debugdraw_fill_texture.sc     
		${BGFX_DIR}/examples/common/debugdraw/fs_debugdraw_lines.bin.h         
		${BGFX_DIR}/examples/common/debugdraw/fs_debugdraw_lines.sc
		${BGFX_DIR}/examples/common/debugdraw/fs_debugdraw_lines_stipple.bin.h  
		${BGFX_DIR}/examples/common/debugdraw/fs_debugdraw_lines_stipple.sc     
		${BGFX_DIR}/examples/common/debugdraw/varying.def.sc                    
		${BGFX_DIR}/examples/common/debugdraw/vs_debugdraw_fill.bin.h           
		${BGFX_DIR}/examples/common/debugdraw/vs_debugdraw_fill.sc              
		${BGFX_DIR}/examples/common/debugdraw/vs_debugdraw_fill_lit.bin.h       
		${BGFX_DIR}/examples/common/debugdraw/vs_debugdraw_fill_lit.sc          
		${BGFX_DIR}/examples/common/debugdraw/vs_debugdraw_fill_lit_mesh.bin.h
		${BGFX_DIR}/examples/common/debugdraw/vs_debugdraw_fill_lit_mesh.sc
		${BGFX_DIR}/examples/common/debugdraw/vs_debugdraw_fill_mesh.bin.h
		${BGFX_DIR}/examples/common/debugdraw/vs_debugdraw_fill_mesh.sc
		${BGFX_DIR}/examples/common/debugdraw/vs_debugdraw_fill_texture.bin.h
		${BGFX_DIR}/examples/common/debugdraw/vs_debugdraw_fill_texture.sc
		${BGFX_DIR}/examples/common/debugdraw/vs_debugdraw_lines.bin.h
		${BGFX_DIR}/examples/common/debugdraw/vs_debugdraw_lines.sc
		${BGFX_DIR}/examples/common/debugdraw/vs_debugdraw_lines_stipple.bin.h
		${BGFX_DIR}/examples/common/debugdraw/vs_debugdraw_lines_stipple.sc
	)

	set(BGFX_COMMON_SRC
		${BGFX_DIR}/examples/common/bgfx_utils.h
		${BGFX_DIR}/examples/common/common.h
		${BGFX_DIR}/examples/common/packrect.h
	)

	set(BGFX_COMMON_IMGUI_SRC
		${BGFX_DIR}/examples/common/imgui/imgui.cpp
		${BGFX_DIR}/examples/common/imgui/imgui.h
		${BGFX_DIR}/examples/common/imgui/droidsans.ttf.h 
		${BGFX_DIR}/examples/common/imgui/fs_imgui_image.bin.h
		${BGFX_DIR}/examples/common/imgui/fs_imgui_image.sc       
		${BGFX_DIR}/examples/common/imgui/fs_ocornut_imgui.bin.h  
		${BGFX_DIR}/examples/common/imgui/fs_ocornut_imgui.sc     
		${BGFX_DIR}/examples/common/imgui/icons_font_awesome.ttf.h  
		${BGFX_DIR}/examples/common/imgui/icons_kenney.ttf.h        
		${BGFX_DIR}/examples/common/imgui/roboto_regular.ttf.h            
		${BGFX_DIR}/examples/common/imgui/robotomono_regular.ttf.h  
		${BGFX_DIR}/examples/common/imgui/varying.def.sc
		${BGFX_DIR}/examples/common/imgui/vs_imgui_image.bin.h
		${BGFX_DIR}/examples/common/imgui/vs_imgui_image.sc
		${BGFX_DIR}/examples/common/imgui/vs_ocornut_imgui.bin.h
		${BGFX_DIR}/examples/common/imgui/vs_ocornut_imgui.sc
	)
endif(ENABLE_IMGUI)

if(ENABLE_NANOVG)
	set(NANOVG_SRC
		${BGFX_DIR}/examples/common/nanovg/fontstash.h      
		${BGFX_DIR}/examples/common/nanovg/fs_nanovg_fill.bin.h
		${BGFX_DIR}/examples/common/nanovg/fs_nanovg_fill.sc
		${BGFX_DIR}/examples/common/nanovg/nanovg_bgfx.cpp
		${BGFX_DIR}/examples/common/nanovg/nanovg_bgfx.h
		${BGFX_DIR}/examples/common/nanovg/nanovg.cpp
		${BGFX_DIR}/examples/common/nanovg/nanovg.h
		${BGFX_DIR}/examples/common/nanovg/vs_nanovg_fill.bin.h
		${BGFX_DIR}/examples/common/nanovg/vs_nanovg_fill.sc
		${BGFX_DIR}/examples/common/nanovg/varying.def.sc
	)
endif(ENABLE_NANOVG)

set(BGFX_INCLUDE_DIRS
	${BGFX_DIR}/include
	${BGFX_DIR}/3rdparty
	${BIMG_DIR}/include
	${BX_DIR}/include
)
if(WIN32)
	set(BGFX_LIBS
		${BGFX_LIB_DIR}/bgfx$<$<CONFIG:Debug>:Debug>$<$<CONFIG:Release>:Release>.lib
		${BGFX_LIB_DIR}/bimg$<$<CONFIG:Debug>:Debug>$<$<CONFIG:Release>:Release>.lib
		${BGFX_LIB_DIR}/bx$<$<CONFIG:Debug>:Debug>$<$<CONFIG:Release>:Release>.lib
	)
	set(BGFX_INCLUDE_DIRS ${BGFX_INCLUDE_DIRS} ${BX_DIR}/include/compat/msvc)
endif(WIN32)

#Shcore.lib?

set(SRC src/BgfxSimpleApp.cpp src/BgfxSimpleApp.h app/IBgfxApp.h)

if(WIN32)
	set(SRC ${SRC}
		app/win32/IBgfxWin32App.h
		app/win32/Win32Application.h
		app/win32/Win32Application.cpp
	)
endif(WIN32)

function(makeGroups fileList baseDir)
	foreach(FILE ${fileList}) 
	    # Get the directory of the source file
	    get_filename_component(PARENT_DIR "${FILE}" DIRECTORY)
	    # Remove common directory prefix to make the group
	    string(REPLACE "${baseDir}" "" GROUP "${PARENT_DIR}")
	    # Make sure we are using windows slashes
	    string(REPLACE "/" "\\" GROUP "${GROUP}")
	    source_group("${GROUP}" FILES "${FILE}")
	endforeach()
endfunction()

makeGroups("${SRC}" ${CMAKE_SOURCE_DIR})

if(ENABLE_IMGUI)
	makeGroups("${BGFX_COMMON_SRC}" ${BGFX_DIR}/examples)
	makeGroups("${BGFX_COMMON_IMGUI_SRC}" ${BGFX_DIR}/examples)
	makeGroups("${BGFX_DEBUGDRAW_SRC}" ${BGFX_DIR}/examples)
	makeGroups("${IMGUI_SRC}" ${BGFX_DIR}/3rdparty)

	set(SRC ${SRC}
		${BGFX_COMMON_SRC}
		${BGFX_COMMON_IMGUI_SRC}
		${BGFX_DEBUGDRAW_SRC}
		${IMGUI_SRC}
	)
endif(ENABLE_IMGUI)

if(ENABLE_NANOVG)
	makeGroups("${NANOVG_SRC}" ${BGFX_DIR}/examples)
	set(SRC ${SRC}
		${NANOVG_SRC}
	)
endif(ENABLE_NANOVG)

add_executable(${PROJECT_NAME} ${SRC})

target_compile_definitions(${PROJECT_NAME} PUBLIC BX_CONFIG_DEBUG=${BX_CONFIG_DEBUG})
target_include_directories(${PROJECT_NAME} PUBLIC ${CMAKE_SOURCE_DIR} src app ${BGFX_INCLUDE_DIRS})
target_link_libraries(${PROJECT_NAME} PUBLIC ${BGFX_LIBS})

if(WIN32)
	target_compile_definitions(${PROJECT_NAME} PUBLIC /wd4201 /wd4324 /Ob2 /Zc:__cplusplus _UNICODE UNICODE -MT$<$<CONFIG:Debug>:d> /SUBSYSTEM:WINDOWS -DPRId64="I64d")
	target_link_options(${PROJECT_NAME} PRIVATE /SUBSYSTEM:WINDOWS /ignore:4221 /ignore:4199)
	set_property(TARGET ${PROJECT_NAME} PROPERTY MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
	set_property(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY VS_STARTUP_PROJECT ${PROJECT_NAME})
	message({CMAKE_CXX_FLAGS_DEBUG} ${CMAKE_CXX_FLAGS_DEBUG})
	message({CMAKE_C_FLAGS_DEBUG} ${CMAKE_C_FLAGS_DEBUG})
endif(WIN32)

if(WIN32)
	set(SHADER_PLATFORM windows)
	set(PROFILE s_5_0)
elseif(APPLE)
	set(SHADER_PLATFORM osx) # or ios
	set(PROFILE metal)
endif()

file(GLOB VS_SHADER_SRC LIST_DIRECTORIES false ${SHADER_DIR}/vs_*.sc)
file(GLOB FS_SHADER_SRC LIST_DIRECTORIES false ${SHADER_DIR}/fs_*.sc)
file(GLOB CS_SHADER_SRC LIST_DIRECTORIES false ${SHADER_DIR}/cs_*.sc)

function(addShaderCompileCommand fileList type)
	foreach(SHADER_SRC_FILE IN LISTS fileList)
		string(REGEX MATCH "^(.*)\\.[^.]*$" dummy ${SHADER_SRC_FILE})
		set(S_SHADER_HDR_FILE ${CMAKE_MATCH_1}.h)
		add_custom_command(
			VERBATIM
			OUTPUT  ${S_SHADER_HDR_FILE}
			DEPENDS ${S_SHADER_SRC_FILE}
			COMMAND ${SHADERC} --platform ${SHADER_PLATFORM} --profile ${PROFILE} --varyingdef ${SHADER_DIR}/varying.def.sc  -i ${BGFX_DIR}/examples/common -i ${BGFX_DIR}/src -f ${S_SHADER_SRC} -o ${S_SHADER_HDR_FILE} --bin2c --type ${type}
			COMMENT "Compiling shader ${SHADER_SRC_FILE} with ${SHADERC}."
		)
		list(APPEND SHADER_HDR_FILES ${S_SHADER_HDR_FILE})
	endforeach()
endfunction()

if(VS_SHADER_SRC)
	addShaderCompileCommand(${VS_SHADER_SRC} v)
endif(VS_SHADER_SRC)
if(FS_SHADER_SRC)
	addShaderCompileCommand(${FS_SHADER_SRC} f)
endif(FS_SHADER_SRC)
if(CS_SHADER_SRC)
	addShaderCompileCommand(${CS_SHADER_SRC} v)
endif(CS_SHADER_SRC)

#message(${SHADER_HDR_FILES}......................{SHADER_HDR_FILES})
add_custom_target(Shaders ALL DEPENDS ${SHADER_HDR_FILES} SOURCES ${VS_SHADER_SRC} ${FS_SHADER_SRC} ${CS_SHADER_SRC})
makeGroups("${VS_SHADER_SRC}" ${CMAKE_SOURCE_DIR})
makeGroups("${FS_SHADER_SRC}" ${CMAKE_SOURCE_DIR})
makeGroups("${CS_SHADER_SRC}" ${CMAKE_SOURCE_DIR})

add_dependencies(${PROJECT_NAME} Shaders)
