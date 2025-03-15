# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.14)

project(llamacpp VERSION 1.0.0 LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_subdirectory(Vulkan-Headers "${CMAKE_CURRENT_BINARY_DIR}/vkheaders" EXCLUDE_FROM_ALL)

if(GGML_VULKAN)
  if(WIN32)
	  add_subdirectory(Vulkan-Loader "${CMAKE_CURRENT_BINARY_DIR}/vkloaders" EXCLUDE_FROM_ALL)
  else()
      find_package(Vulkan REQUIRED)
  endif()
endif()

add_subdirectory(cpuinfo "${CMAKE_CURRENT_BINARY_DIR}/cpuinfo" EXCLUDE_FROM_ALL)

add_subdirectory(llama_cpp "${CMAKE_CURRENT_BINARY_DIR}/llama" EXCLUDE_FROM_ALL)

add_library(llamacpp SHARED "llamacpp.cpp")

target_include_directories(ggml-vulkan PRIVATE Vulkan-Headers/include )

target_include_directories(llamacpp PRIVATE llama_cpp/include llama_cpp/ggml/include llama_cpp/common/include cpuinfo/include)

find_package(Threads REQUIRED)

set_target_properties(llamacpp PROPERTIES
  PUBLIC_HEADER llamacpp.h
  OUTPUT_NAME "llamacpp"
)

target_compile_definitions(llamacpp PUBLIC DART_SHARED_LIB)

target_link_libraries(llamacpp PRIVATE cpuinfo ggml llama common Threads::Threads)

if (ANDROID)
  # Support Android 15 16k page size.
  target_link_options(llamacpp PRIVATE "-Wl,-z,max-page-size=16384")
endif()
