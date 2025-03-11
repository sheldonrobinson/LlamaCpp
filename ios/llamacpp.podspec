#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint llamacpp.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'llamacpp'
  s.version          = '1.0.0'
  s.summary          = 'llamacpp is a dart implementation of llama.cpp. It is a revision of lcpp from mobile artificial intelligence distribution (maid)'
  s.description      = <<-DESC
llamacpp is a dart implementation of llama.cpp. It is a revision of lcpp from mobile artificial intelligence distribution (maid)
                       DESC
  s.homepage         = 'https://github.com/sheldonrobinson/llamacpp'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Sheldon Robinson' => 'sheldon.robison@live.com' }
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
  # n.b. above is standard flutter (modulo missing s.source_files)


  # This will ensure the source files in Classes/ are included in the native
  # builds of apps using this FFI plugin. Podspec does not support relative
  # paths, so Classes contains a forwarder C file that relatively imports
  # `../src/*` so that the C sources can be shared among all target platforms.
  s.source           = { :path => '.' }

  # Add the prepare_command to copy files
  s.prepare_command = <<-CMD
    set -e
    set -u
    set -o pipefail

    SOURCE_DIR="../src"
    TARGET_DIR="./llamacpp"

    # Ensure source directory exists
    if [ ! -d "$SOURCE_DIR" ]; then
        echo "Source directory $SOURCE_DIR does not exist. Exiting."
        exit 1
    fi

    # Remove existing target directory if it exists
    if [ -d "$TARGET_DIR" ]; then
        echo "Removing existing target directory $TARGET_DIR..."
        rm -rf "$TARGET_DIR"
    fi

    # Copy source to target
    echo "Copying $SOURCE_DIR to $TARGET_DIR..."
    cp -R "$SOURCE_DIR" "$TARGET_DIR"

    echo "Copy completed successfully."
  CMD

  s.source_files = 'build-info.c',
				   '*.cpp',	
                   'llamacpp/llama_cpp/src/*.cpp',
                   'llamacpp/llama_cpp/common/*.cpp',
                   'llamacpp/llama_cpp/ggml/src/*.c',
                   'llamacpp/llama_cpp/ggml/src/*.cpp',
                   'llamacpp/llama_cpp/ggml/src/ggml-cpu/*.c',
                   'llamacpp/llama_cpp/ggml/src/ggml-cpu/*.cpp',
                   'llamacpp/llama_cpp/ggml/src/ggml-metal/*.m',
                   '!llamacpp/llama_cpp/common/build-info.cpp'
  s.frameworks = 'Foundation', 'Metal', 'MetalKit'
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'USER_HEADER_SEARCH_PATHS' => [
	  '$(PODS_TARGET_SRCROOT)/llamacpp/llamacpp.h',
      '$(PODS_TARGET_SRCROOT)/llamacpp/llama_cpp/include/llama.h',
      '$(PODS_TARGET_SRCROOT)/llamacpp/llama_cpp/src',
      '$(PODS_TARGET_SRCROOT)/llamacpp/llama_cpp/common', 
      '$(PODS_TARGET_SRCROOT)/llamacpp/llama_cpp/ggml/include',
      '$(PODS_TARGET_SRCROOT)/llamacpp/llama_cpp/ggml/src',
      '$(PODS_TARGET_SRCROOT)/llamacpp/llama_cpp/ggml/src/ggml-cpu',
      '$(PODS_TARGET_SRCROOT)/llamacpp/llama_cpp/ggml/src/ggml-metal',
    ],
    'HEADER_SEARCH_PATHS' => [
	  '$(PODS_TARGET_SRCROOT)/llamacpp/llamacpp.h',
      '$(PODS_TARGET_SRCROOT)/llamacpp/llama_cpp/include/llama.h',
      '$(PODS_TARGET_SRCROOT)/llamacpp/llama_cpp/src',
      '$(PODS_TARGET_SRCROOT)/llamacpp/llama_cpp/common', 
      '$(PODS_TARGET_SRCROOT)/llamacpp/llama_cpp/ggml/include',
      '$(PODS_TARGET_SRCROOT)/llamacpp/llama_cpp/ggml/src',
      '$(PODS_TARGET_SRCROOT)/llamacpp/llama_cpp/ggml/src/ggml-cpu',
      '$(PODS_TARGET_SRCROOT)/llamacpp/llama_cpp/ggml/src/ggml-metal',
    ],
    'OTHER_CFLAGS' => ['$(inherited)', '-O3', '-flto', '-fno-objc-arc', '-w', '-I$(PODS_TARGET_SRCROOT)/llamacpp', '-I$(PODS_TARGET_SRCROOT)/llamacpp/llama_cpp/include', '-I$(PODS_TARGET_SRCROOT)/llamacpp/llama_cpp/ggml/include', '-I$(PODS_TARGET_SRCROOT)/llamacpp/llama_cpp/common', '-DGGML_LLAMAFILE=OFF', '-DGGML_USE_CPU'],
    'OTHER_CPLUSPLUSFLAGS' => ['$(inherited)', '-O3', '-flto', '-fno-objc-arc', '-w', '-std=c++17', '-fpermissive', '-I$(PODS_TARGET_SRCROOT)/llamacpp', '-I$(PODS_TARGET_SRCROOT)/llamacpp/llama_cpp/include', '-I$(PODS_TARGET_SRCROOT)/llamacpp/llama_cpp/ggml/include', '-I$(PODS_TARGET_SRCROOT)/llamacpp/llama_cpp/common', '-DGGML_LLAMAFILE=OFF', '-DGGML_USE_CPU'],
    'GCC_PREPROCESSOR_DEFINITIONS' => ['$(inherited)', 'GGML_USE_METAL=1'],
  }
  s.script_phases = [
    {
      :name => 'Build Metal Library',
      :input_files => ["${PODS_TARGET_SRCROOT}/llamacpp/llama_cpp/ggml/src/ggml-metal.metal"],
      :output_files => ["${METAL_LIBRARY_OUTPUT_DIR}/default.metallib"],
      :execution_position => :after_compile,
      :script => <<-SCRIPT
      set -e
      set -u
      set -o pipefail
      cd "${PODS_TARGET_SRCROOT}/llamacpp/llama_cpp"
      xcrun metal -target "air64-${LLVM_TARGET_TRIPLE_VENDOR}-${LLVM_TARGET_TRIPLE_OS_VERSION}${LLVM_TARGET_TRIPLE_SUFFIX:-\"\"}" -ffast-math -std=ios-metal2.3 -o "${METAL_LIBRARY_OUTPUT_DIR}/default.metallib" ggml/src/ggml-metal/*.metal
      SCRIPT
    }
  ]
end
