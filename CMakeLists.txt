cmake_minimum_required(VERSION 3.0 FATAL_ERROR)

PROJECT(bgfx-simple-app LANGUAGES CXX C)

set(BGFX_DIR ${CMAKE_SOURCE_DIR}/../../npainter/ThirdParty/bgfx)
set(BIMG_DIR ${CMAKE_SOURCE_DIR}/../../npainter/ThirdParty/bimg)
set(BX_DIR ${CMAKE_SOURCE_DIR}/../../npainter/ThirdParty/bx)
set(BGFX_LIB_DIR ${BGFX_DIR}/.build/win64_vs2022/bin)

set(CMAKE_CXX_STANDARD_REQUIRED ON)
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

function(makeGroups fileList)
	foreach(FILE ${fileList}) 
	    # Get the directory of the source file
	    get_filename_component(PARENT_DIR "${FILE}" DIRECTORY)
	    # Remove common directory prefix to make the group
	    string(REPLACE "${APP_PATH}" "" GROUP "${PARENT_DIR}")
	    # Make sure we are using windows slashes
	    string(REPLACE "/" "\\" GROUP "${GROUP}")
	    source_group("${GROUP}" FILES "${FILE}")
	endforeach()
endfunction()

makeGroups("${SRC}")

add_executable(${PROJECT_NAME} ${SRC})

target_compile_definitions(${PROJECT_NAME} PUBLIC BX_CONFIG_DEBUG=${BX_CONFIG_DEBUG})
target_include_directories(${PROJECT_NAME} PUBLIC ${CMAKE_SOURCE_DIR} src app ${BGFX_INCLUDE_DIRS})
target_link_libraries(${PROJECT_NAME} PUBLIC ${BGFX_LIBS})

if(WIN32)
	target_compile_definitions(${PROJECT_NAME} PUBLIC /wd4201 /wd4324 /Ob2 /Zc:__cplusplus _UNICODE UNICODE -MT$<$<CONFIG:Debug>:d> /SUBSYSTEM:WINDOWS)
	target_link_options(${PROJECT_NAME} PRIVATE "-mwindows" /SUBSYSTEM:WINDOWS /ignore:4221 /ignore:4199)
	set_property(TARGET ${PROJECT_NAME} PROPERTY MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>" )
	message({CMAKE_CXX_FLAGS_DEBUG} ${CMAKE_CXX_FLAGS_DEBUG})
	message({CMAKE_C_FLAGS_DEBUG} ${CMAKE_C_FLAGS_DEBUG})
endif(WIN32)
