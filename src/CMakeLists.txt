# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.14)

project(llamacpp VERSION 1.0.0 LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# if(GGML_VULKAN)
 # add_subdirectory("${LLAMACPP_SRC_DIR}/Vulkan-Headers" "${CMAKE_CURRENT_BINARY_DIR}/vkheaders" SYSTEM)
 # add_subdirectory("${LLAMACPP_SRC_DIR}/Vulkan-Loader" "${CMAKE_CURRENT_BINARY_DIR}/vkloaders" SYSTEM)
# endif()

if(GGML_VULKAN)
  add_subdirectory(Vulkan-Headers "${CMAKE_CURRENT_BINARY_DIR}/vkheaders" EXCLUDE_FROM_ALL)
  add_subdirectory(Vulkan-Loader "${CMAKE_CURRENT_BINARY_DIR}/vkloaders" EXCLUDE_FROM_ALL)
endif()

add_subdirectory(llama_cpp "${CMAKE_CURRENT_BINARY_DIR}/llama" EXCLUDE_FROM_ALL)

add_library(llamacpp SHARED "llamacpp.cpp")

target_include_directories(llamacpp PRIVATE llama_cpp/include llama_cpp/ggml/include llama_cpp/common/include)

find_package(Threads REQUIRED)

set_target_properties(llamacpp PROPERTIES
  PUBLIC_HEADER llamacpp.h
  OUTPUT_NAME "llamacpp"
)

target_compile_definitions(llamacpp PUBLIC DART_SHARED_LIB)

target_link_libraries(llamacpp PRIVATE ggml llama common Threads::Threads)

# if(WIN32)
  # target_link_directories(lcpp PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/llama_cpp/binaries/windows/x64/lib")
  # target_link_libraries(lcpp PRIVATE ggml common llguidance Threads::Threads)
# elseif(ANDROID)
  # target_link_directories(lcpp PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/llama_cpp/binaries/android/arm64-v8a")
  # target_link_libraries(lcpp PRIVATE ggml Threads::Threads)
# elseif(Linux)
  # target_link_directories(lcpp PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/llama_cpp/binaries/linux/x64/lib")
  # target_link_libraries(lcpp PRIVATE ggml Threads::Threads)
# endif()

if (ANDROID)
  # Support Android 15 16k page size.
  target_link_options(lcpp PRIVATE "-Wl,-z,max-page-size=16384")
endif()
