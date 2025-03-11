cmake_minimum_required(VERSION 3.22)

# Define the project
project(llamacpp)

# Set CMake flags
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DBUILD_COMMIT=unknown -DBUILD_COMPILER=unknown -DBUILD_TARGET=Android")
add_link_options("LINKER:--hash-style=gnu,--build-id=none")

# Add subdirectory with explicit source and binary directories
add_subdirectory(../src ${CMAKE_BINARY_DIR}/llamacpp_build)
