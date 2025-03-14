cmake_minimum_required(VERSION 3.22)

# Project-level configuration.
set(PROJECT_NAME "llamacpp")
project(${PROJECT_NAME} LANGUAGES CXX C)

set(LLAMACPP_SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../src)

# Set CMake flags
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DBUILD_COMMIT=unknown -DBUILD_COMPILER=unknown -DBUILD_TARGET=Android")
add_link_options("LINKER:--hash-style=gnu,--build-id=none")
set(BUILD_SHARED_LIBS ON)

# Set the linker flags for shared libraries
set(LLAMA_BUILD_COMMON ON CACHE BOOL "llama: build common utils library" FORCE)
# set(LLAMA_LLGUIDANCE ON CACHE BOOL "llama-common: include LLGuidance library for structured output in common utils" FORCE)

set(GGML_OPENMP ON CACHE BOOL "ggml: use OpenMP" FORCE)
set(GGML_VULKAN ON CACHE BOOL "llama: enable vulkan" FORCE)
set(Vulkan_GLSLC_EXECUTABLE "glslc" CACHE FILEPATH "Path to Vulkan glslc executable" FORCE)
# set(GGML_VULKAN_SHADERS_GEN_TOOLCHAIN "vulkan-shaders-gen" CACHE FILEPATH "ggml: toolchain file for vulkan-shaders-gen" FORCE)
set(CMAKE_CROSSCOMPILING ON)

################## cpuinfo settings ###############################
set(CPUINFO_LOG_LEVEL "fatal" CACHE STRING "Minimum logging level (info with lower severity will be ignored)" FORCE)
# set(CPUINFO_LOG_TO_STDIO OFF CACHE BOOL "Log errors, warnings, and information to stdout/stderr" FORCE)
set(CPUINFO_LIBRARY_TYPE "static" CACHE STRING "Type of cpuinfo library (shared, static, or default) to build" FORCE)
set(CPUINFO_BUILD_TOOLS OFF CACHE BOOL "Build command-line tools" FORCE)
set(CPUINFO_BUILD_UNIT_TESTS OFF CACHE BOOL "Build cpuinfo unit tests" FORCE)
set(CPUINFO_BUILD_MOCK_TESTS OFF CACHE BOOL "Build cpuinfo mock tests" FORCE)
set(CPUINFO_BUILD_BENCHMARKS OFF CACHE BOOL "Build cpuinfo micro-benchmarks" FORCE)
set(CPUINFO_BUILD_PKG_CONFIG OFF CACHE BOOL "Build pkg-config manifest" FORCE)

# Add subdirectory with explicit source and binary directories
add_subdirectory("${LLAMACPP_SRC_DIR}" ${CMAKE_BINARY_DIR}/llamacpp_build)

set_target_properties(llamacpp PROPERTIES
  BUILD_WITH_INSTALL_RPATH TRUE
)

target_compile_definitions(llamacpp PUBLIC DART_SHARED_LIB)
