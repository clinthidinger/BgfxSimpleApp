cmake_minimum_required(VERSION 3.0 FATAL_ERROR)

PROJECT(bgfx-simple-app LANGUAGES CXX C)

option(ENABLE_IMGUI "Enable DearImGui" on)
option(ENABLE_NANOVG "Enable nanoVG" on)
option(ENABLE_CINDER_LITE "Enable Cinder-Lite" on)
set(BGFX_DIR ${CMAKE_SOURCE_DIR}/../../npainter/ThirdParty/bgfx)
set(BIMG_DIR ${CMAKE_SOURCE_DIR}/../../npainter/ThirdParty/bimg)
set(BX_DIR ${CMAKE_SOURCE_DIR}/../../npainter/ThirdParty/bx)
#get_filename_component(BGFX_LIB_DIR ${BGFX_DIR}/.build/win64_vs2022/bin ABSOLUTE)
#get_filename_component(SHADERC ${BGFX_DIR}/.build/win64_vs2022/bin/shaderc$<$<CONFIG:Debug>:Debug>$<$<CONFIG:Release>:Release>.exe ABSOLUTE)
set(VS_VERSION vs2022)
get_filename_component(BGFX_LIB_DIR ${BGFX_DIR}/.build/win64_${VS_VERSION}/bin ABSOLUTE)
get_filename_component(SHADERC ${BGFX_DIR}/.build/win64_${VS_VERSION}/bin/shadercDebug.exe ABSOLUTE)
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

set(CINDER_LITE_SRC
	third_party/cinder/circular/circular.h
	third_party/cinder/Area.h
	third_party/cinder/Area.cpp
	third_party/cinder/AxisAlignedBox.h
	third_party/cinder/BandedMatrix.h
	third_party/cinder/BandedMatrix.cpp
	third_party/cinder/BreakPoint.h
	third_party/cinder/BSpline.cpp
	third_party/cinder/BSpline.h
	third_party/cinder/BSplineFit.cpp
	third_party/cinder/BSplineFit.h
	third_party/cinder/Buffer.cpp
	third_party/cinder/Buffer.h
	third_party/cinder/Camera.h
	third_party/cinder/CameraManager.h
	third_party/cinder/Capture.cpp
	third_party/cinder/Capture.h
	third_party/cinder/CaptureImplAvFoundation.h
	third_party/cinder/CaptureImplAvFoundation.mm
	third_party/cinder/Channel.h
	third_party/cinder/ChanTraits.h
	third_party/cinder/Cinder.h
	third_party/cinder/CinderAssert.cpp
	third_party/cinder/CinderAssert.h
	third_party/cinder/CinderFwd.h
	third_party/cinder/CinderGlm.h
	third_party/cinder/CinderMath.cpp
	third_party/cinder/CinderMath.h
	third_party/cinder/Color.cpp
	third_party/cinder/Color.h
	third_party/cinder/CurrentFunction.h
	third_party/cinder/DataSource.cpp
	third_party/cinder/DataSource.h
	third_party/cinder/DataTarget.cpp
	third_party/cinder/DataTarget.h
	third_party/cinder/Easing.h
	third_party/cinder/Exception.cpp
	third_party/cinder/Exception.h
	third_party/cinder/Export.h
	third_party/cinder/Filesystem.h
	third_party/cinder/Frustum.h
	third_party/cinder/GeomIo.cpp
	third_party/cinder/GeomIo.h
	third_party/cinder/ImageIo.h
	third_party/cinder/Log.cpp
	third_party/cinder/Log.h
	third_party/cinder/Matrix.cpp
	third_party/cinder/Matrix.h
	third_party/cinder/Matrix22.h
	third_party/cinder/Matrix33.h
	third_party/cinder/Matrix44.h
	third_party/cinder/Noncopyable.h
	third_party/cinder/Path2d.cpp
	third_party/cinder/Path2d.h
	third_party/cinder/Perlin.h
	third_party/cinder/Plane.h
	third_party/cinder/PolyLine.cpp
	third_party/cinder/PolyLine.h
	third_party/cinder/Quaternion.h
	third_party/cinder/Rand.h
	third_party/cinder/Ray.h
	third_party/cinder/Rect.cpp
	third_party/cinder/Rect.h
	third_party/cinder/Shape2d.cpp
	third_party/cinder/Shape2d.h
	third_party/cinder/Signals.cpp
	third_party/cinder/Signals.h
	third_party/cinder/Sphere.h
	third_party/cinder/Stream.cpp
	third_party/cinder/Stream.h
	third_party/cinder/Surface.h
	third_party/cinder/System.h
	third_party/cinder/Timeline.cpp
	third_party/cinder/Timeline.h
	third_party/cinder/TimelineItem.cpp
	third_party/cinder/TimelineItem.h
	third_party/cinder/Triangulate.cpp
	third_party/cinder/Triangulate.h
	third_party/cinder/TriMesh.cpp
	third_party/cinder/TriMesh.h
	third_party/cinder/Tween.cpp
	third_party/cinder/Tween.h
	#third_party/cinder/Unicode.cpp
	#third_party/cinder/Unicode.h
	#third_party/cinder/Url.cpp
	#third_party/cinder/Url.h
	third_party/cinder/Utilities.cpp
	third_party/cinder/Utilities.h
	third_party/cinder/Vector.h
)

set(LIBTESS2_SRC
	third_party/libtess2/alg_outline.md
	third_party/libtess2/bucketalloc.c
	third_party/libtess2/bucketalloc.h
	third_party/libtess2/dict.c
	third_party/libtess2/dict.h
	third_party/libtess2/geom.c
	third_party/libtess2/geom.h
	third_party/libtess2/include/tesselator.h
	third_party/libtess2/LICENSE.txt
	third_party/libtess2/mesh.c
	third_party/libtess2/mesh.h
	third_party/libtess2/priorityq.c
	third_party/libtess2/priorityq.h
	third_party/libtess2/README.md
	third_party/libtess2/sweep.c
	third_party/libtess2/sweep.h
	third_party/libtess2/tess.c
	third_party/libtess2/tess.h
)

set(ZLIB_SRC
	third_party/zlib/adler32.c
	third_party/zlib/compress.c
	third_party/zlib/crc32.c
	third_party/zlib/crc32.h
	third_party/zlib/deflate.c
	third_party/zlib/deflate.h
	third_party/zlib/gzclose.c
	third_party/zlib/gzguts.h
	third_party/zlib/gzlib.c
	third_party/zlib/gzread.c
	third_party/zlib/gzwrite.c
	third_party/zlib/infback.c
	third_party/zlib/inffast.c
	third_party/zlib/inffast.h
	third_party/zlib/inffixed.h
	third_party/zlib/inflate.c
	third_party/zlib/inflate.h
	third_party/zlib/inftrees.c
	third_party/zlib/inftrees.h
	third_party/zlib/trees.c
	third_party/zlib/trees.h
	third_party/zlib/uncompr.c
	third_party/zlib/zconf.h
	third_party/zlib/zlib.h
	third_party/zlib/zutil.c
	third_party/zlib/zutil.h	
)

set(CINDER_NANOVG_SRC
	third_party/nanovg/bgfx_nanovg_ctx.h
	third_party/nanovg/bgfx_nanovg_ctx.cpp
)

set(SRC 
	src/BgfxSimpleApp.cpp
	src/BgfxSimpleApp.h
	#src/ViewIdTestApp.cpp
	#src/ViewIdTestApp.h
	src/BgfxRect.cpp
	src/BgfxRect.h
	src/BgfxUtil.cpp
	src/BgfxUtil.h
	src/Fbo.cpp
	src/Fbo.h
	app/IBgfxApp.h
)

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
	set(SRC ${SRC} ${NANOVG_SRC})
endif(ENABLE_NANOVG)

if(ENABLE_CINDER_LITE)
	makeGroups("${CINDER_LITE_SRC}" ./)
	makeGroups("${ZLIB_SRC}" ./)
	set(SRC ${SRC} ${CINDER_LITE_SRC} ${LIBTESS2_SRC} ${ZLIB_SRC})
endif(ENABLE_CINDER_LITE)

add_executable(${PROJECT_NAME} ${SRC})

target_compile_definitions(${PROJECT_NAME} PUBLIC BX_CONFIG_DEBUG=${BX_CONFIG_DEBUG})
target_include_directories(${PROJECT_NAME} PUBLIC ${CMAKE_SOURCE_DIR} src app ${BGFX_INCLUDE_DIRS} third_party third_party/zlib)
target_link_libraries(${PROJECT_NAME} PUBLIC ${BGFX_LIBS})

if(WIN32)
	target_compile_definitions(${PROJECT_NAME} PUBLIC _UNICODE UNICODE -DPRId64="I64d" -DPRIu64="I64u" NOMINMAX)
	target_compile_options(${PROJECT_NAME} PRIVATE /wd4201 /wd4324 /wd4996 /Ob2 /Zc:preprocessor /Zc:__cplusplus /SUBSYSTEM:WINDOWS)
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
		set(SHADER_HDR_FILE ${CMAKE_MATCH_1}.h)
		add_custom_command(
			VERBATIM
			OUTPUT  ${SHADER_HDR_FILE}
			DEPENDS ${SHADER_SRC_FILE}
			COMMAND ${SHADERC} --platform ${SHADER_PLATFORM} --profile ${PROFILE} --varyingdef ${SHADER_DIR}/varying.def.sc  -i ${BGFX_DIR}/examples/common -i ${BGFX_DIR}/src -i ${SHADER_DIR} -f ${SHADER_SRC_FILE} -o ${SHADER_HDR_FILE} --bin2c --type ${type}
			COMMENT "Compiling shader ${SHADER_SRC_FILE} with ${SHADERC}."
		)
		list(APPEND SHADER_HDR_FILES ${SHADER_HDR_FILE})
	endforeach()
	set(SHADER_HDR_FILES ${SHADER_HDR_FILES} PARENT_SCOPE)
endfunction()

if(VS_SHADER_SRC)
	message(VS_SHADER_SRC...................${VS_SHADER_SRC})
	addShaderCompileCommand("${VS_SHADER_SRC}" v)
endif(VS_SHADER_SRC)
if(FS_SHADER_SRC)
	addShaderCompileCommand("${FS_SHADER_SRC}" f)
endif(FS_SHADER_SRC)
if(CS_SHADER_SRC)
	addShaderCompileCommand("${CS_SHADER_SRC}" v)
endif(CS_SHADER_SRC)

add_custom_target(Shaders ALL DEPENDS ${SHADER_HDR_FILES} SOURCES ${VS_SHADER_SRC} ${FS_SHADER_SRC} ${CS_SHADER_SRC})
makeGroups("${VS_SHADER_SRC}" ${CMAKE_SOURCE_DIR})
makeGroups("${FS_SHADER_SRC}" ${CMAKE_SOURCE_DIR})
makeGroups("${CS_SHADER_SRC}" ${CMAKE_SOURCE_DIR})

add_dependencies(${PROJECT_NAME} Shaders)
