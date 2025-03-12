# The Flutter tooling requires that developers have a version of Visual Studio
# installed that includes CMake 3.14 or later. You should not increase this
# version, as doing so will cause the plugin to fail to compile for some
# customers of the plugin.
cmake_minimum_required(VERSION 3.10)

# Project-level configuration.
set(PROJECT_NAME "llamacpp")
project(${PROJECT_NAME} LANGUAGES CXX C)

set(LLAMACPP_SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../src)

set(BUILD_SHARED_LIBS ON)
set(CMAKE_INSTALL_LIBDIR lib CACHE PATH "library install dir" FORCE)

# Set the linker flags for shared libraries
set(LLAMA_BUILD_COMMON ON CACHE BOOL "llama: build common utils library" FORCE)
set(LLAMA_LLGUIDANCE ON CACHE BOOL "llama-common: include LLGuidance library for structured output in common utils" FORCE)

set(GGML_NATIVE OFF CACHE BOOL "llama: disable -march=native flag" FORCE)
set(GGML_VULKAN ON CACHE BOOL "llama: enable vulkan" FORCE)
set(GGML_AVX    ON CACHE BOOL "ggml: enable AVX" FORCE)
set(GGML_AVX2   ON CACHE BOOL "ggml: enable AVX2" FORCE)
if (NOT MSVC)
	set(GGML_FMA   ON CACHE BOOL "ggml: enable FMA" FORCE)
	set(GGML_F16C  ON CACHE BOOL "ggml: enable F16C" FORCE)
endif()
set(GGML_OPENMP ON CACHE BOOL "ggml: use OpenMP" FORCE)


add_subdirectory("${LLAMACPP_SRC_DIR}" "${CMAKE_CURRENT_BINARY_DIR}/shared")

set_target_properties(llamacpp PROPERTIES
  BUILD_WITH_INSTALL_RPATH TRUE
)


target_compile_definitions(llamacpp PUBLIC DART_SHARED_LIB)


set(llamacpp_bundled_libraries
  $<TARGET_FILE:llamacpp>
  $<TARGET_FILE:llama>
  $<TARGET_FILE:ggml-vulkan>
  $<TARGET_FILE:ggml-cpu>
  $<TARGET_FILE:ggml-base>
  $<TARGET_FILE:ggml>
  PARENT_SCOPE
)