cmake_minimum_required(VERSION 3.25)

include(FetchContent)

project(
  ImQt
  VERSION 0.1
  DESCRIPTION "Immediate-mode UI system for Qt"
  LANGUAGES CXX)

set(default_build_type "Debug")
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    message(STATUS "Setting build type to '${default_build_type}' as none was specified.")
    set(CMAKE_BUILD_TYPE "${default_build_type}" CACHE
        STRING "Choose the type of build." FORCE)
    # Set the possible values of build type for cmake-gui
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS
    "Debug" "Release") # "RelWithDebInfo" ? "MinSizeRel" ?
endif()

set(CMAKE_CXX_EXTENSIONS OFF)                   # Ensure -std=c++xx instead of -std=g++xx.
set_property(GLOBAL PROPERTY USE_FOLDERS ON)    # Support folders in IDEs.

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)
add_definitions(-DQT_NO_KEYWORDS)

file(GLOB_RECURSE APP_RESRCE_LIST CONFIGURE_DEPENDS "src/*.qrc")
file(GLOB_RECURSE APP_SOURCE_LIST CONFIGURE_DEPENDS "src/*.cpp")
file(GLOB_RECURSE APP_HEADER_LIST CONFIGURE_DEPENDS "src/*.hpp")

file(GLOB_RECURSE APP_FILES CONFIGURE_DEPENDS "src/*.*")

add_executable(ImQt ${APP_RESRCE_LIST} ${APP_SOURCE_LIST} ${APP_HEADER_LIST} ".clang-format" "qt6.natvis")
target_compile_features(ImQt PRIVATE cxx_std_20)

# QT PARAMETERS.
set(CMAKE_AUTOMOC ON)                                   # Qt generator-related parameters.
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)
find_package(Qt6 COMPONENTS Core Gui OpenGL OpenGLWidgets Widgets REQUIRED)
if (${Qt6_FOUND})
    message("Qt ${Qt6_VERSION} was found : " ${Qt6_DIR})
else()
    message("Could not find Qt6. Ensure Qt can be found in the CMAKE_PREFIX_PATH environment variable.")
endif()
target_link_libraries(ImQt PUBLIC
    Qt::Core
    Qt::Gui
    Qt::OpenGL
    Qt::OpenGLWidgets
    Qt::Widgets)

source_group(TREE ${CMAKE_CURRENT_SOURCE_DIR} FILES ${APP_FILES})

#
# Post-build commands.
#

set(QT_DEPLOY_TOOL "${Qt6_DIR}/../../../bin/windeployqt.exe")
file(TO_NATIVE_PATH ${QT_DEPLOY_TOOL} QT_DEPLOY_TOOL)

set(DEBUG_FOLDER "${ImQt_SOURCE_DIR}/build/Debug")
set(RELEASE_FOLDER "${ImQt_SOURCE_DIR}/build/Release")
set(RELWITHDEBINFO_FOLDER "${ImQt_SOURCE_DIR}/build/RelWithDebInfo")
file(TO_NATIVE_PATH ${DEBUG_FOLDER} DEBUG_FOLDER)
file(TO_NATIVE_PATH ${RELEASE_FOLDER} RELEASE_FOLDER)

# Windows deployment.
if(MSVC)
    add_custom_command(TARGET ImQt POST_BUILD
        COMMAND ${QT_DEPLOY_TOOL} 
            "$<IF:$<CONFIG:Debug>,${DEBUG_FOLDER},$<IF:$<CONFIG:RelWithDebInfo>,${RELWITHDEBINFO_FOLDER},${RELEASE_FOLDER}>>"
            --no-translations --no-quick-import
    )
endif()

# TODO: multiplatform deployment.


