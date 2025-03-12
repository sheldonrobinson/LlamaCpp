part of 'package:llamacpp/llamacpp.dart';



ffi.Pointer<ffi.Pointer<lcpp_common_chat_msg_t>> _to_lcpp_common_chat_msg_t(List<cm.ChatMessage> messages) {
  final msgs = ffi.calloc<ffi.Pointer<lcpp_common_chat_msg_t>>(messages.length+1);
  messages.asMap().forEach((idx,msg){
    switch(msg.runtimeType){
      case cm.HumanChatMessage():
        final message = msg as cm.HumanChatMessage;
        msgs[idx].ref.role = "user".toNativeUtf8().cast<ffi.Char>();
        msgs[idx].ref.n_role = "user".length;
        final cm.ChatMessageContent content = message.content;
        switch (content) {
          case ChatMessageContentText():
            msgs[idx].ref.content = content.text.toNativeUtf8().cast<ffi.Char>();
            msgs[idx].ref.n_content = content.text.length;
            break;
          case ChatMessageContentImage():
            msgs[idx].ref.content_parts = ffi.calloc<ffi.Pointer<lcpp_common_chat_msg_content_part_t>>(2);
            if(content.mimeType!=null){
              msgs[idx].ref.content_parts[0].ref.type = content.mimeType!.toNativeUtf8().cast<ffi.Char>();
              msgs[idx].ref.content_parts[0].ref.n_type = content.mimeType!.length;
            }
            msgs[idx].ref.content_parts[0].ref.text = content.data.toNativeUtf8().cast<ffi.Char>();
            msgs[idx].ref.content_parts[0].ref.n_text = content.data.length;
            msgs[idx].ref.content_parts[1] = ffi.nullptr;
          case ChatMessageContentMultiModal():
            if(content.parts.isNotEmpty) {
              msgs[idx].ref.content_parts = ffi.calloc<
                  ffi.Pointer<lcpp_common_chat_msg_content_part_t>>(
                  content.parts.length + 1);
              content.parts.asMap().forEach((inx, part) {
                switch (part.runtimeType) {
                  case ChatMessageContentText():
                    final text = part as ChatMessageContentText;
                    msgs[idx].ref.content_parts[inx].ref.text =
                        text.text.toNativeUtf8().cast<ffi.Char>();
                    msgs[idx].ref.content_parts[inx].ref.n_text =
                        text.text.length;
                    break;
                  case ChatMessageContentImage():
                    final image = part as ChatMessageContentImage;
                    if (image.mimeType != null) {
                      msgs[idx].ref.content_parts[inx].ref.type =
                          image.mimeType!.toNativeUtf8().cast<ffi.Char>();
                      msgs[idx].ref.content_parts[inx].ref.n_type =
                          image.mimeType!.length;
                    }
                    msgs[idx].ref.content_parts[inx].ref.text =
                        image.data.toNativeUtf8().cast<ffi.Char>();
                    msgs[idx].ref.content_parts[inx].ref.n_text =
                        image.data.length;
                    break;

                  case ChatMessageContentMultiModal():
                    msgs[idx].ref.content_parts[inx].ref.text =
                        "".toNativeUtf8().cast<ffi.Char>();
                    msgs[idx].ref.content_parts[inx].ref.n_text = "".length;
                    break;
                }
              });
              msgs[idx].ref.content_parts[content.parts.length] = ffi.nullptr;
            }
            break;
        }
        break;
      case cm.AIChatMessage():
        final message = msg as cm.AIChatMessage;
        msgs[idx].ref.role = "assistant".toNativeUtf8().cast<ffi.Char>();
        msgs[idx].ref.n_role = "assistant".length;
        msgs[idx].ref.content = message.content.toNativeUtf8().cast<ffi.Char>();
        msgs[idx].ref.n_content = message.content.length;
        if(message.toolCalls.isNotEmpty){
          msgs[idx].ref.tool_calls = ffi.calloc<ffi.Pointer<lcpp_common_chat_tool_call>>(message.toolCalls.length+1);
          message.toolCalls.asMap().forEach((inx, part) {
            msgs[idx].ref.tool_calls[inx].ref.name = part.name.toNativeUtf8().cast<ffi.Char>();
            msgs[idx].ref.tool_calls[inx].ref.n_name = part.name.length;
            String json = JsonEncoder().convert(part.arguments);
            msgs[idx].ref.tool_calls[inx].ref.arguments = json.toNativeUtf8().cast<ffi.Char>();
            msgs[idx].ref.tool_calls[inx].ref.n_arguments = json.length;
            msgs[idx].ref.tool_calls[inx].ref.id = part.id.toNativeUtf8().cast<ffi.Char>();
            msgs[idx].ref.tool_calls[inx].ref.n_id = part.id.length;

          });
          msgs[idx].ref.tool_calls[message.toolCalls.length] = ffi.nullptr;
        }
        break;
      case cm.ToolChatMessage():
        msgs[idx].ref.role = "tool".toNativeUtf8().cast<ffi.Char>();
        msgs[idx].ref.n_role = "tool".length;
        final message = msg as cm.ToolChatMessage;
        msgs[idx].ref.tool_call_id = message.toolCallId.toNativeUtf8().cast<ffi.Char>();
        msgs[idx].ref.n_tool_call_id = message.toolCallId.length;
        msgs[idx].ref.content = message.content.toNativeUtf8().cast<ffi.Char>();
        msgs[idx].ref.n_content = message.content.length;
        break;
      case cm.SystemChatMessage():
        msgs[idx].ref.role = "system".toNativeUtf8().cast<ffi.Char>();
        msgs[idx].ref.n_role = "system".length;
        final message = msg as cm.SystemChatMessage;
        msgs[idx].ref.content = message.content.toNativeUtf8().cast<ffi.Char>();
        msgs[idx].ref.n_content = message.content.length;
        break;
      case cm.CustomChatMessage():
        final message = msg as cm.CustomChatMessage;
        msgs[idx].ref.role = message.role.toNativeUtf8().cast<ffi.Char>();
        msgs[idx].ref.n_role = message.role.length;
        msgs[idx].ref.content = message.content.toNativeUtf8().cast<ffi.Char>();
        msgs[idx].ref.n_content = message.content.length;
        break;
    }
  });
  msgs[messages.length] = ffi.nullptr;
  return msgs;
}

extension LLamaCppChatMessages on PromptValue {
  ffi.Pointer<ffi.Pointer<lcpp_common_chat_msg_t>> toNative() {
    final messages = toChatMessages();
    return _to_lcpp_common_chat_msg_t(messages);
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
class LlamaCpp  with ChangeNotifier {

  static ffi.DynamicLibrary? _lib;
  static final LIBNAME = 'llamacpp';
  static void _init(){
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

  Stream<LLMResult> prompt(PromptValue messages, {bool streaming = true}) async* {
    if (kDebugMode) {
      print('LlamaNative::prompt($messages)');
    }
    
    

    // ffi.Pointer<llama_chat_message> messagesPtr = messagesCopy.toNative();

    ffi.NativeCallable<LppTokenStreamCallback_tFunction>? nativeNewTokenCallable;

    final StreamController<LLMResult> responseStreamController =
    StreamController.broadcast(
      onCancel: () {
        if(streaming){
          if (nativeNewTokenCallable != null) {
            nativeNewTokenCallable!.close();
            lcpp_unset_token_stream_callback();
            nativeNewTokenCallable = null;
          }
        }

      },
      sync: true
    );

    void onNewTokenCallback(ffi.Pointer<ffi.Char> text, ffi.Pointer<ffi.Uint32> length) {
      if (kDebugMode) {
        print('onNewTokenCallback');
      }
      try {
        responseStreamController.add(
          LLMResult(id: DateTime.now().millisecondsSinceEpoch.toString(),
              output: text.cast<ffi.Utf8>().toDartString(length: length.value),
              finishReason: FinishReason.unspecified,
              metadata: {},
              usage: const LanguageModelUsage(),
              streaming: true)
        );
      } finally {
        if (kDebugMode) {
          print('onNewTokenCallback::finally');
        }
        ffi.calloc.free(text);
      }
      if (kDebugMode) {
        print('onNewTokenCallback:>');
      }
    }

    if(streaming){
      if (kDebugMode) {
        print('set_new_token_callback()');
      }
      nativeNewTokenCallable =
      ffi.NativeCallable<LppTokenStreamCallback_tFunction>.listener(
        onNewTokenCallback,
      );

      nativeNewTokenCallable!.keepIsolateAlive = false;

      lcpp_set_token_stream_callback(
          nativeNewTokenCallable!.nativeFunction);

      if(kDebugMode) {
        print('set_new_token_callback:>');
      }
    }

    LLMResult result;

    ffi.NativeCallable<LppChatMessageCallback_tFunction>? chatMessageCallable;

    void chatMessageCallback(lcpp_common_chat_msg_t message) {
      if (kDebugMode) {
        print('chatMessageCallback');
      }
      try {
        final Map<String, dynamic> metadata = Map<String, dynamic>();
        final output = message.n_content > 0 ? message.content.cast<ffi.Utf8>().toDartString(length: message.n_content) : '';
        if(message.n_role > 0){
          metadata['role'] = message.role.cast<ffi.Utf8>().toDartString(length: message.n_role);
        }

        if(message.n_reasoning_content > 0){
          metadata['reasoning_content'] = message.reasoning_content.cast<ffi.Utf8>().toDartString(length: message.n_reasoning_content);
        }

        if(message.n_tool_name > 0){
          metadata['tool_name'] = message.tool_name.cast<ffi.Utf8>().toDartString(length: message.n_tool_name);
        }

        if(message.n_tool_call_id > 0){
          metadata['tool_call_id'] = message.tool_call_id.cast<ffi.Utf8>().toDartString(length: message.n_tool_call_id);
        }

        List<Map<String,String>> content_parts = List<Map<String,String>>.empty(growable: true);
        if(message.n_content_parts > 0){
          final content_parts_ptr = message.content_parts;
          for(int i =0; i < message.n_content_parts; i++){
            Map<String,String> _current = {};
            final it = content_parts_ptr + i;
            if(it.value.ref.n_text > 0){
              _current['text'] = it.value.ref.text.cast<ffi.Utf8>().toDartString(length: it.value.ref.n_text);
            }
            if(it.value.ref.n_type > 0){
              _current['type'] = it.value.ref.type.cast<ffi.Utf8>().toDartString(length: it.value.ref.n_type);
            }
            if(_current.isNotEmpty){
              content_parts.add(_current);
            }
          }
        }

        if(content_parts.isNotEmpty){
          metadata['content_parts'] = content_parts;
        }

        List<Map<String,String>> tool_calls = List<Map<String,String>>.empty(growable: true);
        if(message.n_tool_calls > 0){
          final tool_calls_ptr = message.tool_calls;
          for(int i =0; i < message.n_tool_calls; i++){
            Map<String,String> _current = {};
            final it = tool_calls_ptr + i;
            if(it.value.ref.n_name > 0){
              _current['name'] = it.value.ref.name.cast<ffi.Utf8>().toDartString(length: it.value.ref.n_name);
            }
            if(it.value.ref.n_id > 0){
              _current['id'] = it.value.ref.id.cast<ffi.Utf8>().toDartString(length: it.value.ref.n_id);
            }
            if(it.value.ref.n_arguments > 0){
              _current['arguments'] = it.value.ref.arguments.cast<ffi.Utf8>().toDartString(length: it.value.ref.n_arguments);
            }
            if(_current.isNotEmpty){
              tool_calls.add(_current);
            }
          }
        }
        if(tool_calls.isNotEmpty){
          metadata['tool_calls'] = tool_calls;
        }

        result = LLMResult(id: DateTime.now().millisecondsSinceEpoch.toString(),
            output: output,
            finishReason: tool_calls.isNotEmpty ? FinishReason.toolCalls : FinishReason.stop,
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
      }
      if (kDebugMode) {
        print('chatMessageCallback:>');
      }
    }

    if (kDebugMode) {
      print('set_chat_message_callback()');
    }
    chatMessageCallable =
    ffi.NativeCallable<LppChatMessageCallback_tFunction>.listener(
      chatMessageCallback,
    );

    lcpp_set_chat_message_callback(
        chatMessageCallable!.nativeFunction);

    if(kDebugMode) {
      print('set_chat_message_callback:>');
    }
    final chatMessages = messages.toChatMessages();
    lcpp_prompt(_to_lcpp_common_chat_msg_t(chatMessages), chatMessages.length);

    /// Stream of token responses.
    await for (final response in responseStreamController.stream){
        yield response;
        if(response.finishReason == FinishReason.stop || response.finishReason == FinishReason.toolCalls)
          break;
    }

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

    lcpp_detokenize(input, tokens.length, special, special, result);

    final text = result.ref.found ? result.ref.value.cast<ffi.Utf8>().toDartString(length: result.ref.length) : '';

    if(result.ref.found){
      ffi.malloc.free(result.ref.value);
    }

    ffi.malloc.free(input);
    ffi.malloc.free(result);
    return text;
  }

  List<int> tokenize(String text) {
    final input = text.toNativeUtf8();

    final tokens = ffi.malloc<ffi.Pointer<llama_token>>();
    int nTokens = lcpp_tokenize(text.toNativeUtf8().cast<ffi.Char>(),
        input.length, true, true, tokens);

    final result = nTokens > 0 ? tokens.value.asTypedList(nTokens).toList(growable: false)
    : List<int>.empty(growable: false);
    ffi.malloc.free(tokens);
    ffi.calloc.free(input);
    return result;
  }

  String description() {
    final result = ffi.malloc<lcpp_data_pvalue>();
    lcpp_model_description(result);
    final text = result.ref.found ? result.ref.value.cast<ffi.Utf8>().toDartString(length: result.ref.length) : '';
    if(result.ref.found){
      ffi.malloc.free(result.ref.value);
    }
    ffi.malloc.free(result);
    return text;
  }

  String architecture() {
    final result = ffi.malloc<lcpp_data_pvalue>();
    lcpp_model_architecture(result);
    final text = result.ref.found ? result.ref.value.cast<ffi.Utf8>().toDartString(length: result.ref.length) : '';
    if(result.ref.found){
      ffi.malloc.free(result.ref.value);
    }
    ffi.malloc.free(result);
    return text;
  }

  void reset(){
    lcpp_reset();
  }

  void destroy(){
    lcpp_destroy();
  }
}
