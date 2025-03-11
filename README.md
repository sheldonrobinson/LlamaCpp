# LlamaCpp

[![Build Android](https://github.com/sheldonrobinson/llamacpp/actions/workflows/build-android.yml/badge.svg)](https://github.com/Mobile-Artificial-Intelligence/lcpp/actions/workflows/build-android.yml)
[![Build Linux](https://github.com/Mobile-Artificial-Intelligence/lcpp/actions/workflows/build-linux.yml/badge.svg)](https://github.com/sheldonrobinson/llamacpp/actions/workflows/build-linux.yml)
[![Build MacOS](https://github.com/Mobile-Artificial-Intelligence/lcpp/actions/workflows/build-macos.yml/badge.svg)](https://github.com/sheldonrobinson/llamacpp/actions/workflows/build-macos.yml)
[![Build Windows](https://github.com/Mobile-Artificial-Intelligence/lcpp/actions/workflows/build-windows.yml/badge.svg)](https://github.com/sheldonrobinson/llamacpp/actions/workflows/build-windows.yml)

LlamaCpp is a dart implementation of llama.cpp. It is a fork/revision of lcpp from mobile artificial intelligence distribution (maid)

## Features
- Streaming support

## Getting started

To use this package, add `llamacpp` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

```yaml
dependencies:
  lcpp: ^1.0.0
```

then you can import llama in your Dart code

```dart
import 'package:llamacpp/llamacpp.dart';
```

## Usage

Below is a simple example of how to use llama

```dart
final llm = LlamaCpp(
  lcppParams: LcppParams(
    model_path: 'path/to/model',
  ),
);

final messages = [
  ChatMessage.withRole(role: 'user', content: 'Hello World'),
];

final stream = llm.prompt(messages);

stream.listen((event) {
  print(event);
});
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details
```
MIT License

Copyright (c) 2025 Sheldon Robinson

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
