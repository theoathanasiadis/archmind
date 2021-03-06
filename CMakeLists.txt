#Project archmind
cmake_minimum_required(VERSION 2.6)

if(NOT DEFINED CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release)
endif()

project(archmind)

set(
    BOOST_INC_SEARCH_PATH
    $ENV{BOOST_ROOT}
    #append additional search directories for boost include directories here
    )

set(
    BOOST_LIB_SEARCH_PATH
    $ENV{BOOST_LIBRARYDIR}
    #append additional search directories for boost libraries here
)

set(CMAKE_INCLUDE_PATH ${CMAKE_INCLUDE_PATH} ${BOOST_INC_SEARCH_PATH})
set(CMAKE_LIBRARY_PATH ${CMAKE_LIBRARY_PATH} ${BOOST_LIB_SEARCH_PATH})

set(
    OPENCL_INC_SEARCH_PATH
    ${OPENCL_INCLUDE_DIR}
    ${OPENCL_DIR}/OpenCL/common/inc
    $ENV{OPENCL_INCLUDE_DIR}
    $ENV{CUDA_INC_PATH}
    $ENV{INTELOCLSDKROOT}/include
    /usr/local/include
    /usr/include
    ./include
    #append additional search directories for OpenCL include here
    )

set(
    OPENCL_LIB_SEARCH_PATH
    ${OPENCL_LIBRARY_DIR}
    ${OPENCL_DIR}/lib
    ${OPENCL_DIR}/lib/x86
    $ENV{OPENCL_LIBRARY_DIR}
    $ENV{OPENCL_DIR}/lib
    $ENV{OPENCL_DIR}/lib/x86
    $ENV{LD_LIBRARY_PATH}
    $ENV{CUDA_LIB_PATH}
    $ENV{INTELOCLSDKROOT}/lib/x64
    $ENV{INTELOCLSDKROOT}/lib/x86
    /usr/local/lib64
    /usr/local/lib
    /usr/lib64
    /usr/lib
    ./lib
    #append additional search directories for OpenCL libraries here.
)

find_path(OPENCL_INCLUDE_DIR NAMES CL/cl.h PATHS ${OPENCL_INC_SEARCH_PATH})
find_library(OPENCL_LIBRARIES NAMES OpenCL PATHS ${OPENCL_LIB_SEARCH_PATH})

find_package(PythonLibs)
#add_definitions(-DBOOST_ALL_NO_LIB )

#Boost options turn on/off according to the type of linking
set(Boost_USE_STATIC_LIBS ON) 
set(Boost_USE_MULTITHREADED ON)
set(Boost_USE_STATIC_RUNTIME OFF)
set(Boost_DEBUG OFF)

find_package(Boost 1.40 COMPONENTS program_options REQUIRED)

set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -D_DEBUG")

if(MSVC)
  add_definitions(-D_SCL_SECURE_NO_WARNINGS -D_HAS_ITERATOR_DEBUGGING=0 -D_SECURE_SCL=0)
endif()

if(PYTHONLIBS_FOUND) 
  add_subdirectory(src/Python lib)
else()
  set(PYTHON_INCLUDE_DIRS $ENV{PYTHON_ROOT}/include)
  set(PYTHON_LIBRARIES $ENV{PYTHON_ROOT}/libs)
  #add_subdirectory(src/Python)
endif()

add_subdirectory(examples/cpp cpp_examples)
add_subdirectory(examples/sphere_mapping sphere_mapping)
add_subdirectory(examples/constrained_mapping constrained_mapping)

