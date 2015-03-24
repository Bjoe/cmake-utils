# ------------------------------------------------------------------------------
#  BlackBerry CMake toolchain file, for use with the BlackBerry 10 NDK 
#  Requires cmake 2.6.3 or newer (2.8.3 or newer is recommended).
#
#  Usage Linux:
#   $ source /absolute/path/to/the/bbndk/bbndk-env.sh
#   $ mkdir build
#   $ cd build
#   $ cmake -DCMAKE_MODULE_PATH="..../cmake" -DCMAKE_TOOLCHAIN_FILE="..../cmake/toolchain/blackberry.toolchain.cmake" -G "Eclipse CDT4 - Unix Makefiles" path/project
#   $ make -j8
#
# -DTargetPlatform="BlackBerry" 
#
#  Usage Mac:
#   Same as the steps on Linux
#
#  Usage Windows:
#   > /absolute/path/to/the/bbndk/bbndk-env.bat
#   > mkdir build
#   > cd build
#   > cmake -DCMAKE_MODULE_PATH="..../cmake" -DCMAKE_TOOLCHAIN_FILE="..../cmake/toolchain/blackberry.toolchain.cmake" -G "Eclipse CDT4 - Unix Makefiles" path/project
#   > make -j8
#

cmake_minimum_required( VERSION 2.8)

if( DEFINED CMAKE_CROSSCOMPILING )
  # Subsequent toolchain loading is not really needed
  return()
endif()

# There may be a way to make cmake reduce these TODO
if("$ENV{CPUVARDIR}" STREQUAL "x86")
 set(BLACKBERRY_ARCHITECTURE "x86")
 set(NEUTRINO_ARCH "" )
 set(NDK_ARCH "x86")
else()
 set(BLACKBERRY_ARCHITECTURE "arm")
 set(NEUTRINO_ARCH "v7" )
 set(NDK_ARCH "armle-v7")
 set(QMAKE_ARCH "armv7le")
endif()

set( BLACKBERRY_TOOLCHAIN_ROOT "$ENV{QNX_HOST}" )
set( BLACKBERRY_TARGET_ROOT "$ENV{QNX_TARGET}" )
set( CMAKE_SYSTEM_NAME QNX )
set( CMAKE_SYSTEM_VERSION 1 )

# Detect host platform
set( TOOL_OS_SUFFIX "" )
if( CMAKE_HOST_APPLE )
 set( BLACKBERRY_NDK_HOST_SYSTEM_NAME "darwin-x86" )
elseif( CMAKE_HOST_WIN32 )
 set( BLACKBERRY_NDK_HOST_SYSTEM_NAME "windows" )
 set( TOOL_OS_SUFFIX ".exe" )
elseif( CMAKE_HOST_UNIX )
 set(BLACKBERRY_NDK_HOST_SYSTEM_NAME "linux-x86" )
else()
 message( FATAL_ERROR "Cross-compilation on your platform is not supported by this cmake toolchain" )
endif()

# Specify the cross compiler
set( CMAKE_C_COMPILER   "$ENV{QNX_HOST}/usr/bin/qcc${TOOL_OS_SUFFIX}"                CACHE PATH "gcc" )
set( CMAKE_CXX_COMPILER "$ENV{QNX_HOST}/usr/bin/qcc${TOOL_OS_SUFFIX}"                CACHE PATH "g++" )
set( CMAKE_ASM_COMPILER "$ENV{QNX_HOST}/usr/bin/nto${BLACKBERRY_ARCHITECTURE}${NEUTRINO_ARCH}-gcc${TOOL_OS_SUFFIX}"   CACHE PATH "Assembler" )
#set( CMAKE_ASM_COMPILER "$ENV{QNX_HOST}/usr/bin/qcc${TOOL_OS_SUFFIX}"                CACHE PATH "Assembler" )
if( CMAKE_VERSION VERSION_LESS 2.8.5 )
 set( CMAKE_ASM_COMPILER_ARG1 "-c" )
endif()

set( CMAKE_STRIP        "$ENV{QNX_HOST}/usr/bin/nto${BLACKBERRY_ARCHITECTURE}-strip${TOOL_OS_SUFFIX}"       CACHE PATH "strip" )
set( CMAKE_AR           "$ENV{QNX_HOST}/usr/bin/nto${BLACKBERRY_ARCHITECTURE}-ar${TOOL_OS_SUFFIX}"          CACHE PATH "archive" )
set( CMAKE_LINKER       "$ENV{QNX_HOST}/usr/bin/nto${BLACKBERRY_ARCHITECTURE}${NEUTRINO_ARCH}-ld${TOOL_OS_SUFFIX}"        CACHE PATH "linker" )
set( CMAKE_NM           "$ENV{QNX_HOST}/usr/bin/nto${BLACKBERRY_ARCHITECTURE}${NEUTRINO_ARCH}-nm${TOOL_OS_SUFFIX}"        CACHE PATH "nm" )
set( CMAKE_OBJCOPY      "$ENV{QNX_HOST}/usr/bin/nto${BLACKBERRY_ARCHITECTURE}${NEUTRINO_ARCH}-objcopy${TOOL_OS_SUFFIX}"   CACHE PATH "objcopy" )
set( CMAKE_OBJDUMP      "$ENV{QNX_HOST}/usr/bin/nto${BLACKBERRY_ARCHITECTURE}${NEUTRINO_ARCH}-objdump${TOOL_OS_SUFFIX}"   CACHE PATH "objdump" )
set( CMAKE_RANLIB       "$ENV{QNX_HOST}/usr/bin/nto${BLACKBERRY_ARCHITECTURE}-ranlib${TOOL_OS_SUFFIX}"      CACHE PATH "ranlib" )

# Installer
if( APPLE )
  # hack for Apple: if a new cmake (which uses CMAKE_INSTALL_NAME_TOOL) runs on an old build tree
  # (where install_name_tool was hardcoded) and where CMAKE_INSTALL_NAME_TOOL isn't in the cache
  # and still cmake didn't fail in CMakeFindBinUtils.cmake (because it isn't rerun)
  # hardcode CMAKE_INSTALL_NAME_TOOL here to install_name_tool, so it behaves as it did before, Alex
  if (NOT DEFINED CMAKE_INSTALL_NAME_TOOL)
    find_program(CMAKE_INSTALL_NAME_TOOL install_name_tool)
  endif (NOT DEFINED CMAKE_INSTALL_NAME_TOOL)
  # find_program( CMAKE_INSTALL_NAME_TOOL NAMES install_name_tool )
  # if( NOT CMAKE_INSTALL_NAME_TOOL )
  #  message( FATAL_ERROR "Could not find install_name_tool, please check your #installation." )
  # endif()
  mark_as_advanced( CMAKE_INSTALL_NAME_TOOL )
endif()

# Flags and preprocessor definitions
if( BLACKBERRY_ARCHITECTURE STREQUAL "arm" )
 set( BLACKBERRY_CC_FLAGS  "-V4.8.3,gcc_ntoarmv7le_cpp -mcpu=cortex-a9" ) 
 set( BLACKBERRY_CXX_FLAGS "-V4.8.3,gcc_ntoarmv7le_cpp -mcpu=cortex-a9" )
 set( BLACKBERRY_LINKER_FLAGS "-Vgcc_ntoarmv7le_cpp" )
 set( CMAKE_CXX_FLAGS_RELEASE "-fstack-protector-strong -O2 -Os -D_FORTIFY_SOURCE=2 -DQT_NO_DEBUG -fPIE -fvisibility=hidden" ) #  -mthumb -fPIC -shared
 set( CMAKE_C_FLAGS_RELEASE   "-fstack-protector-strong -O2 -Os -D_FORTIFY_SOURCE=2 -DQT_NO_DEBUG -fPIE -fvisibility=hidden" ) #  -mthumb -fPIC -shared
 set( CMAKE_CXX_FLAGS_DEBUG   "-marm -finline-limit=64" )
 set( CMAKE_C_FLAGS_DEBUG     "-marm -finline-limit=64 " )
else()
 set( BLACKBERRY_CC_FLAGS  " -V4.8.3,gcc_ntox86_cpp" )
 set( BLACKBERRY_CXX_FLAGS " -V4.8.3,gcc_ntox86_cpp" )
endif()


# NDK flags
set( CMAKE_INCPATH "-I${BLACKBERRY_TARGET_ROOT}/qnx6/usr/include -I${BLACKBERRY_TARGET_ROOT}/qnx6/usr/share/qt4/mkspecs/blackberry-${QMAKE_ARCH}-qcc -I${BLACKBERRY_TARGET_ROOT}/qnx6/usr/include/qt4/QtCore -I${BLACKBERRY_TARGET_ROOT}/qnx6/usr/include/qt4/QtGui -I${BLACKBERRY_TARGET_ROOT}/qnx6/usr/include/qt4 -I${BLACKBERRY_TARGET_ROOT}/qnx6/usr/include/freetype2 -I${BLACKBERRY_TARGET_ROOT}/usr/include/bb/device -I${BLACKBERRY_TARGET_ROOT}/usr/include/bb -I${BLACKBERRY_TARGET_ROOT}/usr/include/bb/system")
# set( CMAKE_INCPATH_DEBUG "-Idebug")
# set( CMAKE_INCPATH_RELEASE "-Irelease")
set( CMAKE_CXX_FLAGS "${BLACKBERRY_CXX_FLAGS}  -lang-c++ -fstack-protector -fstack-protector-all -fexceptions  -Wno-psabi -D__QNX__ -D_REENTRANT -DQT_NO_IMPORT_QT47_QML -DQ_OS_BLACKBERRY -DQT_DECLARATIVE_LIB -DQT_GUI_LIB -DQT_CORE_LIB -DQT_SHARED -Wno-unused-local-typedefs")
set( CMAKE_C_FLAGS "${BLACKBERRY_CC_FLAGS} -fstack-protector -fstack-protector-all  -Wno-psabi -D__QNX__ -D_REENTRANT -DQT_NO_IMPORT_QT47_QML -DQ_OS_BLACKBERRY -DQT_DECLARATIVE_LIB -DQT_GUI_LIB -DQT_CORE_LIB -DQT_SHARED -Wno-unused-local-typedefs")
set( CMAKE_CXX_FLAGS_DEBUG "-g ${CMAKE_CXX_FLAGS_DEBUG} -DQT_DECLARATIVE_DEBUG -Wno-unused-local-typedefs")
set( CMAKE_C_FLAGS_DEBUG "-g ${CMAKE_C_FLAGS_DEBUG} -DQT_DECLARATIVE_DEBUG -Wno-unused-local-typedefs")

# Cache flags
set( CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${CMAKE_INCPATH}" CACHE STRING "c++ flags" )
set( CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${CMAKE_INCPATH}" CACHE STRING "c flags" )
set( CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE}" CACHE STRING "c++ Release flags" )
set( CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE}" CACHE STRING "c Release flags" )
set( CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG}" CACHE STRING "c++ Debug flags" )
set( CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG}" CACHE STRING "c Debug flags" )
set( CMAKE_SHARED_LINKER_FLAGS "${BLACKBERRY_LINKER_FLAGS}" CACHE STRING "linker flags" )
SET( CMAKE_SHARED_LIBRARY_LINK_CXX_FLAGS "${BLACKBERRY_LINKER_FLAGS}" CACHE STRING "linker flags")
SET( CMAKE_SHARED_LIBRARY_LINK_C_FLAGS "${BLACKBERRY_LINKER_FLAGS}" CACHE STRING "linker flags")
set( CMAKE_MODULE_LINKER_FLAGS "${BLACKBERRY_LINKER_FLAGS} -Wl,-rpath-link,${BLACKBERRY_TARGET_ROOT}/qnx6/${NDK_ARCH}/lib -Wl,-rpath-link,${BLACKBERRY_TARGET_ROOT}/qnx6/${NDK_ARCH}/usr/lib -L${BLACKBERRY_TARGET_ROOT}/qnx6/${NDK_ARCH}/lib -L${BLACKBERRY_TARGET_ROOT}/qnx6/${NDK_ARCH}/usr/lib -Wl,-rpath-link,${BLACKBERRY_TARGET_ROOT}/qnx6/${NDK_ARCH}/usr/lib/qt4/lib -L${BLACKBERRY_TARGET_ROOT}/qnx6/${NDK_ARCH}/usr/lib/qt4/lib" CACHE STRING "linker flags" )
set( CMAKE_EXE_LINKER_FLAGS "${BLACKBERRY_LINKER_FLAGS} -lm -lbps" CACHE STRING "linker flags" )
set( CMAKE_EXE_LINKER_FLAGS_RELEASE "-Wl,-O1 -Wl,-z,relro -Wl,-z,now -Wl,--strip-all" CACHE STRING "linker flags" ) # Activate Read-only relocations (RELRO) + (GOT)

# Finish flags
set( BLACKBERRY_CXX_FLAGS    "${BLACKBERRY_CXX_FLAGS}"    CACHE INTERNAL "Extra BlackBerry compiler flags")
set( BLACKBERRY_LINKER_FLAGS "${BLACKBERRY_LINKER_FLAGS}" CACHE INTERNAL "Extra BlackBerry linker flags")
#set( CMAKE_CXX_FLAGS  "${BLACKBERRY_CXX_FLAGS}" )
#set( CMAKE_C_FLAGS    "${BLACKBERRY_CXX_FLAGS}" )

set(QT_QMAKE_EXECUTABLE "${BLACKBERRY_TOOLCHAIN_ROOT}/usr/bin/qmake" CACHE FILEPATH "Qt qmake")

# Find the Target environment 
set(CMAKE_FIND_ROOT_PATH 
  "${BLACKBERRY_TARGET_ROOT}"
  "${CMAKE_BINARY_DIR}"
  "${CMAKE_INSTALL_PREFIX}"
  "${CMAKE_SOURCE_DIR}"
)
# Search for libraries and includes in the ndk toolchain
if( APPLE )
  set( CMAKE_FIND_ROOT_PATH_MODE_PROGRAM BOTH )
  set( CMAKE_FIND_ROOT_PATH_MODE_LIBRARY BOTH )
  set( CMAKE_FIND_ROOT_PATH_MODE_INCLUDE BOTH )
else()
  set( CMAKE_FIND_ROOT_PATH_MODE_PROGRAM ONLY )
  set( CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY )
  set( CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY )
endif()

# Macro to find packages on the host OS
#macro( find_host_package )
# set( CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER )
# set( CMAKE_FIND_ROOT_PATH_MODE_LIBRARY NEVER )
# set( CMAKE_FIND_ROOT_PATH_MODE_INCLUDE NEVER )
# if( CMAKE_HOST_WIN32 )
#  SET( WIN32 1 )
#  SET( UNIX )
# elseif( CMAKE_HOST_APPLE )
#  SET( APPLE 1 )
#  SET( UNIX )
# endif()
# find_package( ${ARGN} )
# SET( WIN32 )
# SET( APPLE )
# SET( UNIX 1 )
# set( CMAKE_FIND_ROOT_PATH_MODE_PROGRAM ONLY )
# set( CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY )
# set( CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY )
#endmacro()
#
## Macro to find programs on the host OS
#macro( find_host_program )
# set( CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER )
# set( CMAKE_FIND_ROOT_PATH_MODE_LIBRARY NEVER )
# set( CMAKE_FIND_ROOT_PATH_MODE_INCLUDE NEVER )
# if( CMAKE_HOST_WIN32 )
#  SET( WIN32 1 )
#  SET( UNIX )
# elseif( CMAKE_HOST_APPLE )
#  SET( APPLE 1 )
#  SET( UNIX )
# endif()
# find_program( ${ARGN} )
# SET( WIN32 )
# SET( APPLE )
# SET( UNIX 1 )
# set( CMAKE_FIND_ROOT_PATH_MODE_PROGRAM ONLY )
# set( CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY )
# set( CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY )
#endmacro()
#
## We are doing cross compiling, reset the OS information of the Building system
#UNSET( APPLE )
#UNSET( WIN32 )
#UNSET( UNIX )
#
