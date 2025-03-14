part of 'package:llamacpp/llamacpp.dart';

ffi.Pointer<ffi.Pointer<lcpp_common_chat_msg_t>> convertToLcppCommonChatMsg(
    List<cm.ChatMessage> messages) {
  List<ffi.Pointer<lcpp_common_chat_msg>> _list_common_msgs =
      List<ffi.Pointer<lcpp_common_chat_msg>>.empty(growable: true);
  messages.asMap().forEach((idx, msg) {
    switch (msg) {
      case cm.HumanChatMessage():
        if (kDebugMode) {
          print("HumanChatMessage()");
        }
        final msgPtr = ffi.calloc<lcpp_common_chat_msg>();
        msgPtr.ref.role = "user".toNativeUtf8().cast<ffi.Char>();
        msgPtr.ref.n_role = "user".length;
        final cm.ChatMessageContent content = msg.content;
        switch (content) {
          case cm.ChatMessageContentText():
            if (kDebugMode) {
              print("HumanChatMessage::ChatMessageContentText");
            }
            msgPtr.ref.content = content.text.toNativeUtf8().cast<ffi.Char>();
            msgPtr.ref.n_content = content.text.length;
            break;
          case cm.ChatMessageContentImage():
            if (kDebugMode) {
              print("HumanChatMessage::ChatMessageContentImage");
            }
            final _content_part = ffi.calloc<lcpp_common_chat_msg_content_part>();
            msgPtr.ref.content_parts =
                ffi.calloc<ffi.Pointer<lcpp_common_chat_msg_content_part>>(1);
            if (content.mimeType != null) {
              _content_part.ref.type =
                  content.mimeType!.toNativeUtf8().cast<ffi.Char>();
              _content_part.ref.n_type = content.mimeType!.length;
            } else {
              _content_part.ref.type = "".toNativeUtf8().cast<ffi.Char>();;
              _content_part.ref.n_type = 0;
            }
            _content_part..ref.text =
                content.data.toNativeUtf8().cast<ffi.Char>();
            _content_part..ref.n_text = content.data.length;
            msgPtr.ref.content_parts[0] = _content_part;
            msgPtr.ref.n_content_parts = 1;
            break;
          case cm.ChatMessageContentMultiModal():
            if (kDebugMode) {
              print("HumanChatMessage::ChatMessageContentMultiModal");
            }
            if (content.parts.isNotEmpty) {
              msgPtr.ref.content_parts =
                  ffi.calloc<ffi.Pointer<lcpp_common_chat_msg_content_part>>(
                      content.parts.length);
              List<ffi.Pointer<lcpp_common_chat_msg_content_part>> _list_content_parts =
              List<ffi.Pointer<lcpp_common_chat_msg_content_part>>.empty(growable: true);
              content.parts.forEach((part) {
                switch (part) {
                  case cm.ChatMessageContentText():
                    if (kDebugMode) {
                      print(
                          "ChatMessageContentMultiModal::ChatMessageContentText");
                    }
                    final _context_part = ffi.calloc<lcpp_common_chat_msg_content_part>();
                    _context_part.ref.text =
                        part.text.toNativeUtf8().cast<ffi.Char>();
                    _context_part.ref.n_text = part.text.length;
                    _list_content_parts.add(_context_part);
                    break;
                  case cm.ChatMessageContentImage():
                    if (kDebugMode) {
                      print(
                          "ChatMessageContentMultiModal::ChatMessageContentImage");
                    }
                    final _context_part = ffi.calloc<lcpp_common_chat_msg_content_part>();
                    if (part.mimeType != null) {
                      _context_part.ref.type =
                          part.mimeType!.toNativeUtf8().cast<ffi.Char>();
                      _context_part.ref.n_type =
                          part.mimeType!.length;
                    } else {
                      _context_part.ref.type = "".toNativeUtf8().cast<ffi.Char>();
                      _context_part.ref.n_type = 0;
                    }
                    _context_part.ref.text =
                        part.data.toNativeUtf8().cast<ffi.Char>();
                    _context_part.ref.n_text =
                        part.data.length;
                    _list_content_parts.add(_context_part);
                    break;

                  case cm.ChatMessageContentMultiModal():
                    // final _context_part = ffi.calloc<lcpp_common_chat_msg_content_part>();
                    // _context_part.ref.type = "".toNativeUtf8().cast<ffi.Char>();
                    // _context_part.ref.n_type = 0;
                    // _context_part.ref.text =
                    //     "".toNativeUtf8().cast<ffi.Char>();
                    // _context_part.ref.n_text = "".length;
                    // _list_content_parts.add(_context_part);
                    break;
                }
              });
              _list_content_parts.asMap().forEach((idx, value) {
                if (kDebugMode) {
                  print("_list_content_parts[$idx]");
                }
                msgPtr.ref.content_parts[idx] = value;
              });
            }
            break;
        }
        _list_common_msgs.add(msgPtr);
        break;
      case cm.AIChatMessage():
        if (kDebugMode) {
          print("AIChatMessage()");
        }
        final msgPtr = ffi.calloc<lcpp_common_chat_msg>();
        msgPtr.ref.role = "assistant".toNativeUtf8().cast<ffi.Char>();
        msgPtr.ref.n_role = "assistant".length;
        msgPtr.ref.content = msg.content.toNativeUtf8().cast<ffi.Char>();
        msgPtr.ref.n_content = msg.content.length;
        if (msg.toolCalls.isNotEmpty) {
          msgPtr.ref.tool_calls =
              ffi.calloc<ffi.Pointer<lcpp_common_chat_tool_call>>(
                  msg.toolCalls.length);
          List<ffi.Pointer<lcpp_common_chat_tool_call>> _list_tool_calls =
          List<ffi.Pointer<lcpp_common_chat_tool_call>>.empty(growable: true);
          msg.toolCalls.forEach((part) {
            final _tool_call = ffi.calloc<lcpp_common_chat_tool_call>();
            _tool_call.ref.name =
                part.name.toNativeUtf8().cast<ffi.Char>();
            _tool_call.ref.n_name = part.name.length;
            String json = JsonEncoder().convert(part.arguments);
            _tool_call.ref.arguments =
                json.toNativeUtf8().cast<ffi.Char>();
            _tool_call.ref.n_arguments = json.length;
            _tool_call.ref.id =
                part.id.toNativeUtf8().cast<ffi.Char>();
            _tool_call.ref.n_id = part.id.length;
            _list_tool_calls.add(_tool_call);
          });
          _list_tool_calls.asMap().forEach((idx, value) {
            if (kDebugMode) {
              print("_list_tool_calls[$idx]");
            }
            msgPtr.ref.tool_calls[idx] = value;
          });
        }
        _list_common_msgs.add(msgPtr);
        break;
      case cm.ToolChatMessage():
        if (kDebugMode) {
          print("ToolChatMessage()");
        }
        final msgPtr = ffi.calloc<lcpp_common_chat_msg>();
        msgPtr.ref.role = "tool".toNativeUtf8().cast<ffi.Char>();
        msgPtr.ref.n_role = "tool".length;
        msgPtr.ref.tool_call_id =
            msg.toolCallId.toNativeUtf8().cast<ffi.Char>();
        msgPtr.ref.n_tool_call_id = msg.toolCallId.length;
        msgPtr.ref.content = msg.content.toNativeUtf8().cast<ffi.Char>();
        msgPtr.ref.n_content = msg.content.length;
        _list_common_msgs.add(msgPtr);
        break;
      case cm.SystemChatMessage():
        if (kDebugMode) {
          print("SystemChatMessage()");
        }
        final msgPtr = ffi.calloc<lcpp_common_chat_msg>();
        msgPtr.ref.role = "system".toNativeUtf8().cast<ffi.Char>();
        msgPtr.ref.n_role = "system".length;
        msgPtr.ref.content = msg.content.toNativeUtf8().cast<ffi.Char>();
        msgPtr.ref.n_content = msg.content.length;
        _list_common_msgs.add(msgPtr);
        break;
      case cm.CustomChatMessage():
        if (kDebugMode) {
          print("CustomChatMessage()");
        }
        final msgPtr = ffi.calloc<lcpp_common_chat_msg>();
        msgPtr.ref.role = msg.role.toNativeUtf8().cast<ffi.Char>();
        msgPtr.ref.n_role = msg.role.length;
        msgPtr.ref.content = msg.content.toNativeUtf8().cast<ffi.Char>();
        msgPtr.ref.n_content = msg.content.length;
        _list_common_msgs.add(msgPtr);
        break;
    }
  });
  final msgs = ffi.calloc<ffi.Pointer<lcpp_common_chat_msg_t>>(messages.length);
  _list_common_msgs.asMap().forEach((idx, value) {
    if (kDebugMode) {
      print("_list_common_msgs[$idx]");
    }
    msgs[idx] = value;
  });
  return msgs;
}

extension _PromptValueToLlamaCppChatMessagesExtension on PromptValue {
  ffi.Pointer<ffi.Pointer<lcpp_common_chat_msg_t>> toNative() {
    final messages = toChatMessages();
    return convertToLcppCommonChatMsg(messages);
  }
}

extension _ChatMessageToLlamaCppChatMessagesExtension on List<cm.ChatMessage> {
  ffi.Pointer<ffi.Pointer<lcpp_common_chat_msg_t>> toNative() {
    return convertToLcppCommonChatMsg(this);
  }
}

extension _FreeLlamaCppChatMessagesExtension
    on ffi.Pointer<ffi.Pointer<lcpp_common_chat_msg_t>> {
  void free(int length) {
    for (var i = 0; i < length; i++) {
      final msg = this[i];
      if (msg.ref.content != ffi.nullptr) {
        ffi.calloc.free(msg.ref.content);
      }
      if (msg.ref.role != ffi.nullptr) {
        ffi.calloc.free(msg.ref.role);
      }
      if (msg.ref.tool_call_id != ffi.nullptr) {
        ffi.calloc.free(msg.ref.tool_call_id);
      }
      if (msg.ref.n_content_parts > 0 && msg.ref.content_parts != ffi.nullptr) {
        for (var j = 0; j < msg.ref.n_content_parts; j++) {
          final part = msg.ref.content_parts[j];
          if (part.ref.text != ffi.nullptr) {
            ffi.calloc.free(part.ref.text);
          }
          if (part.ref.type != ffi.nullptr) {
            ffi.calloc.free(part.ref.type);
          }
        }
        ffi.calloc.free(msg.ref.content_parts);
      }
      if (msg.ref.n_tool_calls > 0 && msg.ref.tool_calls != ffi.nullptr) {
        for (var j = 0; j < msg.ref.n_tool_calls; j++) {
          final part = msg.ref.tool_calls[j];
          if (part.ref.name != ffi.nullptr) {
            ffi.calloc.free(part.ref.name);
          }
          if (part.ref.arguments != ffi.nullptr) {
            ffi.calloc.free(part.ref.arguments);
          }
          if (part.ref.id != ffi.nullptr) {
            ffi.calloc.free(part.ref.id);
          }
        }
        ffi.calloc.free(msg.ref.tool_calls);
      }
      ffi.calloc.free(msg);
    }
    ffi.calloc.free(this);
  }
}

/// A class that implements the Llama interface and provides functionality
/// for loading and interacting with a Llama model, context, and sampler.
///
/// The class initializes the model, context, and sampler based on the provided
/// parameters and allows for prompting the model with chat messages.
///
/// The class also provides methods to stop the current operation and free
/// the allocated resources.
///
/// Example usage:
/// ```dart
/// final lcpp = Lcpp(
///   modelParams: ModelParams(...),
///   contextParams: ContextParams(...),
///   lcppParams: LcppParams(...)
/// );
///
/// final responseStream = llamacpp.prompt([...]);
/// responseStream.listen((response) {
///   print(response);
/// });
/// ```
///
/// Properties:
/// - `modelParams`: Sets the model parameters and initializes the model.
/// - `contextParams`: Sets the context parameters and initializes the context.
/// - `lcppParams`: Sets the common params.
///
/// Methods:
/// - `prompt(List<ChatMessage> messages, {bool streaming = true})`: Prompts the model with the given chat messages and returns a stream of responses.
/// - `stop()`: Stops the current operation.
/// - `free()`: Frees the allocated resources.
class LlamaCpp with ChangeNotifier {
  static ffi.DynamicLibrary? _lib;
  static final LIBNAME = 'llamacpp';
  static void _init() {
    if (_lib == null) {
      if (Platform.isWindows) {
        _lib = ffi.DynamicLibrary.open('$LIBNAME.dll');
      } else if (Platform.isLinux || Platform.isAndroid) {
        _lib = ffi.DynamicLibrary.open('lib$LIBNAME.so');
      } else if (Platform.isMacOS || Platform.isIOS) {
        _lib = ffi.DynamicLibrary.open('$LIBNAME.framework/$LIBNAME');
      } else {
        throw LlamaException('Unsupported platform');
      }
    }
  }

  static ffi.DynamicLibrary get lib {
    _init();
    return _lib!;
  }

  ModelParams _modelParams;
  ContextParams _contextParams;
  LlamaCppParams _lcppParams;

  set modelParams(ModelParams modelParams) {
    _modelParams = modelParams;
  }

  set contextParams(ContextParams contextParams) {
    _contextParams = contextParams;
  }

  set lcppParams(LlamaCppParams lcppParams) {
    _lcppParams = lcppParams;
  }

  /// A class that initializes and manages a native Llama model.
  ///
  /// The [LlamaCpp] constructor requires [ModelParams] and optionally accepts
  /// [ContextParams] and [LlamaCppParams]. It initializes the model by loading
  /// the necessary backends and calling the `_initModel` method.
  ///
  /// Example usage:
  /// ```dart
  /// final llamaNative = LlamaNative(
  ///   modelParams: ModelParams(...),
  ///   contextParams: ContextParams(...),
  ///   samplingParams: SamplingParams(...),
  /// );
  /// ```
  ///
  /// Parameters:
  /// - [modelParams]: The parameters required to configure the model.
  /// - [contextParams]: Optional parameters for the context configuration. Defaults to an empty [ContextParams] object.
  /// - [lcppParams]: Optional parameters for the sampling configuration. Defaults to an empty [LlamaCppParams] object.
  LlamaCpp(
      {required ModelParams modelParams,
      ContextParams? contextParams,
      LlamaCppParams lcppParams = const LlamaCppParams()})
      : _modelParams = modelParams,
        _contextParams = contextParams ?? ContextParams(),
        _lcppParams = lcppParams {
    _init();
    reconfigure();
  }

  void reconfigure() {
    final model_params = _modelParams.toNative();
    final context_params = _contextParams.toNative();
    final lcpp_params = _lcppParams.toNative();
    lcpp_reconfigure(model_params, context_params, lcpp_params);
  }

  Stream<LLMResult> prompt(PromptValue messages,
      {bool streaming = true}) async* {
    if (kDebugMode) {
      print('LlamaCpp::prompt($messages)');
    }

    final chatMessages = messages.toChatMessages();
    final commonChatMessages = chatMessages.toNative();
    final id_prefix = DateTime.now().millisecondsSinceEpoch.toString();
    int token_count = 0;

    // ffi.Pointer<llama_chat_message> messagesPtr = messagesCopy.toNative();

    ffi.NativeCallable<LppTokenStreamCallbackFunction>?
        nativeNewTokenCallable;

    final StreamController<LLMResult> responseStreamController =
        StreamController.broadcast(
            onCancel: () {
              if (streaming) {
                if (nativeNewTokenCallable != null) {
                  nativeNewTokenCallable!.close();
                  lcpp_unset_token_stream_callback();
                  nativeNewTokenCallable = null;
                }
              }
            },
            sync: true);

    void onNewTokenCallback(
        ffi.Pointer<ffi.Char> value, int length) {
      if (kDebugMode) {
        print('onNewTokenCallback');
      }
      try {
        final output = length > 0 ? value.cast<ffi.Utf8>().toDartString() : '';
        if (kDebugMode) {
          print('tok: $output');
        }
        token_count++;
        responseStreamController.add(LLMResult(
            id: '$id_prefix #$token_count',
            output:output,
            finishReason: FinishReason.unspecified,
            metadata: {},
            usage: const LanguageModelUsage(),
            streaming: true));
      } finally {
        if (kDebugMode) {
          print('onNewTokenCallback::finally');
        }
        // ffi.calloc.free(value);
      }
      if (kDebugMode) {
        print('onNewTokenCallback:>');
      }
    }

    if (streaming) {
      if (kDebugMode) {
        print('set_new_token_callback()');
      }
      nativeNewTokenCallable =
          ffi.NativeCallable<LppTokenStreamCallbackFunction>.listener(
        onNewTokenCallback,
      );

      nativeNewTokenCallable!.keepIsolateAlive = false;

      lcpp_set_token_stream_callback(nativeNewTokenCallable!.nativeFunction);

      if (kDebugMode) {
        print('set_new_token_callback:>');
      }
    }

    LLMResult result;

    ffi.NativeCallable<LppChatMessageCallbackFunction>? chatMessageCallable;

    void chatMessageCallback(ffi.Pointer<lcpp_common_chat_msg_t> message) {
      if (kDebugMode) {
        print('chatMessageCallback');
      }
      try {
        final Map<String, dynamic> metadata = Map<String, dynamic>();
        final output = message.ref.n_content > 0
            ? message.ref.content
                .cast<ffi.Utf8>()
                .toDartString()
            : '';
        if (message.ref.n_role > 0) {
          metadata['role'] = message.ref.role
              .cast<ffi.Utf8>()
              .toDartString();
        }

        if (message.ref.n_reasoning_content > 0) {
          metadata['reasoning_content'] = message.ref.reasoning_content
              .cast<ffi.Utf8>()
              .toDartString();
        }

        if (message.ref.n_tool_name > 0) {
          metadata['tool_name'] = message.ref.tool_name
              .cast<ffi.Utf8>()
              .toDartString();
        }

        if (message.ref.n_tool_call_id > 0) {
          metadata['tool_call_id'] = message.ref.tool_call_id
              .cast<ffi.Utf8>()
              .toDartString();
        }

        List<Map<String, String>> content_parts =
            List<Map<String, String>>.empty(growable: true);
        if (message.ref.n_content_parts > 0) {
          final contentPartsPtr = message.ref.content_parts;
          for (int i = 0; i < message.ref.n_content_parts; i++) {
            Map<String, String> _current = {};
            final it = contentPartsPtr + i;
            if (it.value.ref.n_text > 0) {
              _current['text'] = it.value.ref.text
                  .cast<ffi.Utf8>()
                  .toDartString();
            }
            if (it.value.ref.n_type > 0) {
              _current['type'] = it.value.ref.type
                  .cast<ffi.Utf8>()
                  .toDartString();
            }
            if (_current.isNotEmpty) {
              content_parts.add(_current);
            }
          }
        }

        if (content_parts.isNotEmpty) {
          metadata['content_parts'] = content_parts;
        }

        List<Map<String, String>> tool_calls =
            List<Map<String, String>>.empty(growable: true);
        if (message.ref.n_tool_calls > 0) {
          final tool_calls_ptr = message.ref.tool_calls;
          for (int i = 0; i < message.ref.n_tool_calls; i++) {
            Map<String, String> _current = {};
            final it = tool_calls_ptr + i;
            if (it.value.ref.n_name > 0) {
              _current['name'] = it.value.ref.name
                  .cast<ffi.Utf8>()
                  .toDartString();
            }
            if (it.value.ref.n_id > 0) {
              _current['id'] = it.value.ref.id
                  .cast<ffi.Utf8>()
                  .toDartString();
            }
            if (it.value.ref.n_arguments > 0) {
              _current['arguments'] = JsonEncoder().convert(it.value.ref.arguments
                  .cast<ffi.Utf8>()
                  .toDartString());
            }
            if (_current.isNotEmpty) {
              tool_calls.add(_current);
            }
          }
        }
        if (tool_calls.isNotEmpty) {
          metadata['tool_calls'] = JsonEncoder().convert(tool_calls);
        }

        result = LLMResult(
            id: id_prefix,
            output: output,
            finishReason: tool_calls.isNotEmpty
                ? FinishReason.toolCalls
                : FinishReason.stop,
            metadata: metadata,
            usage: const LanguageModelUsage(),
            streaming: false);
        responseStreamController.add(result);
      } finally {
        if (kDebugMode) {
          print('chatMessageCallback::finally');
        }
        if (chatMessageCallable != null) {
          chatMessageCallable!.close();
          lcpp_unset_chat_message_callback();
          chatMessageCallable = null;
        }
        lcpp_common_chat_msg_free(message);
      }
      if (kDebugMode) {
        print('chatMessageCallback:>');
      }
    }

    if (kDebugMode) {
      print('set_chat_message_callback()');
    }
    chatMessageCallable =
        ffi.NativeCallable<LppChatMessageCallbackFunction>.listener(
      chatMessageCallback,
    );

    lcpp_set_chat_message_callback(chatMessageCallable!.nativeFunction);

    if (kDebugMode) {
      print('set_chat_message_callback:>');
    }

    lcpp_prompt(commonChatMessages, chatMessages.length);

    /// Stream of token responses.
    await for (final response in responseStreamController.stream) {
      yield response;
      if (response.finishReason == FinishReason.stop ||
          response.finishReason == FinishReason.toolCalls) break;
    }

    commonChatMessages.free(chatMessages.length);
    lcpp_clear_token_stream_responses();
    // lcpp_clear_chat_msg_strings();
    if (kDebugMode) {
      print('LlamaCpp::prompt:>');
    }
  }

  void stop() {
    lcpp_send_abort_signal(true);
  }

  String detokenize(List<int> tokens, bool special) {
    final input = ffi.malloc<ffi.Int>(tokens.length);
    for (int index = 0; index < tokens.length; index++) {
      input[index] = tokens[index];
    }

    final result = ffi.malloc<lcpp_data_pvalue>();

    lcpp_detokenize(input, tokens.length, special, result);

    final text = result.ref.found
        ? result.ref.value
            .cast<ffi.Utf8>()
            .toDartString()
        : '';

    if (result.ref.found) {
      ffi.malloc.free(result.ref.value);
    }

    ffi.malloc.free(input);
    ffi.malloc.free(result);
    return text;
  }

  List<int> tokenize(String text) {
    final input = text.toNativeUtf8();

    final tokens = ffi.malloc<ffi.Pointer<llama_token>>();
    int nTokens = lcpp_tokenize(
        text.toNativeUtf8().cast<ffi.Char>(), input.length, true, true, tokens);

    final result = nTokens > 0
        ? tokens.value.asTypedList(nTokens).toList(growable: false)
        : List<int>.empty(growable: false);
    ffi.malloc.free(tokens);
    ffi.calloc.free(input);
    return result;
  }

  String description() {
    final result = ffi.malloc<lcpp_data_pvalue>();
    lcpp_model_description(result);
    final text = result.ref.found
        ? result.ref.value
            .cast<ffi.Utf8>()
            .toDartString()
        : '';
    if (result.ref.found) {
      ffi.malloc.free(result.ref.value);
    }
    ffi.malloc.free(result);
    return text;
  }

  String architecture() {
    final result = ffi.malloc<lcpp_data_pvalue>();
    lcpp_model_architecture(result);
    final text = result.ref.found
        ? result.ref.value
            .cast<ffi.Utf8>()
            .toDartString()
        : '';
    if (result.ref.found) {
      ffi.malloc.free(result.ref.value);
    }
    ffi.malloc.free(result);
    return text;
  }

  void reset() {
    lcpp_reset();
  }

  void destroy() {
    lcpp_destroy();
  }
}
