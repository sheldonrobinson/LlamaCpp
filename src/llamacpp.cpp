#include <float.h>
#include <time.h>
#include <threads.h>
#include <string.h>
#include <queue>
#include <atomic>
#include <string>


#include "llamacpp.h"

#include "common.h"

#include "chat.h"

#include "sampling.h"

#include "llama-impl.h"

#include "llama-context.h"


#if defined(__WIN32__) || defined(_WIN32) || defined(WIN32) || defined(__WINDOWS__) || defined(__TOS_WIN__)

#include <windows.h>

inline void delay(unsigned long ms)
{
	Sleep(ms);
}

#else  /* presume POSIX */

#include <unistd.h>

inline void delay(unsigned long ms)
{
	usleep(ms * 1000);
}

#endif

typedef struct common_params common_params_t;

typedef struct common_init_result common_init_result_t;

typedef struct llama_vocab llama_vocab_t;

typedef struct common_chat_msg common_chat_msg_t;

typedef struct lcpp_prompt_args {
	const llama_chat_message* messages;
  int n_messages;
} lcpp_prompt_args_t;

static std::atomic<bool> _abort{ false };

LppTokenStreamCallback_t TokenStreamCallback = nullptr;

LppChatMessageCallback_t ChatMessageCallback = nullptr;

typedef struct common_init_result_deleter {
	void operator()(common_init_result_t* result) {
		if (!result->lora.empty()) {
			size_t len = result->lora.size();
			for (int i = 0; i < len; i++) {
				llama_adapter_lora_free(result->lora[i].get());
			}
		}

		llama_free(result->context.get());
		llama_model_free(result->model.get());
	}
} common_init_result_deleter_t;

typedef std::unique_ptr<common_init_result_t, common_init_result_deleter_t> common_init_result_ptr;

static common_init_result_ptr _result;

typedef struct common_sampler common_sampler_t;

typedef struct common_sampler_deleter {
	void operator()(common_sampler_t* gsmpl) {
		common_sampler_free(gsmpl);
	}
} common_sampler_deleter_t;

typedef std::unique_ptr<common_sampler_t, common_sampler_deleter_t> common_sampler_ptr;

void lcpp_common_chat_msg_free(lcpp_common_chat_msg_t* msg) {
	if (msg) {
		if (msg->content != nullptr) {
			free(msg->content);
		}

		if (msg->role != nullptr) {
			free(msg->role);
		}

		if (msg->n_content_parts > 0) {
			if (msg->content_parts != nullptr) {
				for (int i = 0; i < msg->n_content_parts; i++) {
					if (msg->content_parts[i]->text != nullptr) {
						free(msg->content_parts[i]->text);
					}
					if (msg->content_parts[i]->type != nullptr) {
						free(msg->content_parts[i]->type);
					}

				}
			}
			
		}

		if (msg->n_tool_calls > 0) {
			if (msg->tool_calls != nullptr) {
				for (int i = 0; i < msg->n_tool_calls; i++) {
					if (msg->tool_calls[i]->arguments != nullptr) {
						free(msg->tool_calls[i]->arguments);
					}
					if (msg->tool_calls[i]->name != nullptr) {
						free(msg->tool_calls[i]->name);
					}
					if (msg->tool_calls[i]->id != nullptr) {
						free(msg->tool_calls[i]->id);
					}

				}
			}

		}

		if (msg->reasoning_content != nullptr) {
			free(msg->reasoning_content);
		}

		if (msg->tool_name != nullptr) {
			free(msg->tool_name);
		}

		if (msg->tool_call_id) {
			free(msg->tool_call_id);
		}
		delete msg;
	}
}

typedef struct lcpp_common_chat_msg_deleter {
	void operator()(lcpp_common_chat_msg_t* msg) {
		lcpp_common_chat_msg_free(msg);
	}
} lcpp_common_chat_msg_deleter_t;

typedef std::unique_ptr<lcpp_common_chat_msg_t, lcpp_common_chat_msg_deleter_t> lcpp_common_chat_msg_ptr;

static common_sampler_ptr _sampler;

static common_chat_templates_ptr _chat_templates;

static std::atomic<bool> _use_jinja{ false };

static std::atomic<int> _chat_format{ COMMON_CHAT_FORMAT_CONTENT_ONLY };

static std::string _system_prompt;

lcpp_params_t lcpp_sampling_params_defaults() {

	const char* dry_sequence_breakers[4] = { "\n", ":", "\"", "*" };

	lcpp_common_sampler_type_t samplers[8] = {
			LCPP_COMMON_SAMPLER_TYPE_PENALTIES,
			LCPP_COMMON_SAMPLER_TYPE_DRY,
			LCPP_COMMON_SAMPLER_TYPE_TOP_K,
			LCPP_COMMON_SAMPLER_TYPE_TYPICAL_P,
			LCPP_COMMON_SAMPLER_TYPE_TOP_P,
			LCPP_COMMON_SAMPLER_TYPE_MIN_P,
			LCPP_COMMON_SAMPLER_TYPE_XTC,
			LCPP_COMMON_SAMPLER_TYPE_TEMPERATURE
	};

	lcpp_params_t result = {
		/* <= 0.0 to sample greedily, 0.0 to not output probabilities float temp =*/
		0.80f,
		/* 0.0 = disabled float dynatemp_range =*/
		0.00f,
		/* controls how entropy maps to temperature in dynamic temperature sampler float dynatemp_exponent =*/
		1.00f,
		/* 1.0 = disabled float top_p =*/
		0.95f,
		/* 0.0 = disabled float min_p =*/
		0.05f,
		/* 0.0 = disabled float xtc_probability =*/
		0.00f,
		/* > 0.5 disables XTC float xtc_threshold =*/
		0.10f,
		/* typical_p, 1.0 = disabled float typ_p =*/
		1.00f,
		/* 1.0 = disabled float penalty_repeat =*/
		1.00f,
		/* 0.0 = disabled float penalty_freq =*/
		0.00f,
		/* 0.0 = disabled float penalty_present =*/
		0.00f,
		/* 0.0 = disabled; DRY repetition penalty for tokens extending repetition: float dry_multiplier =*/
		0.0f,
		/* 0.0 = disabled; multiplier* base ^ (length of sequence before token - allowed length) float dry_base =*/
		1.75f,
		/* -1.0 = disabled float top_n_sigma =*/
		-1.00f,
		/* target entropy float mirostat_tau =*/
		5.00f,
		/* learning rate float mirostat_eta =*/
		0.10f,
		/* the seed used to initialize llama_sampler, uint32_t seed =*/
		LLAMA_DEFAULT_SEED,
		/* number of previous tokens to remember int32_t n_prev = */
		64,
		/* if greater than 0, output the probabilities of top n_probs tokens. int32_t n_probs =*/
		0,
		/* 0 = disabled, otherwise samplers should return at least min_keep tokens int32_t min_keep =*/
		0,
		/* <= 0 to use vocab size int32_t top_k = */
		40,
		/* last n tokens to penalize (0 = disable penalty, -1 = context size) int32_t penalty_last_n =*/
		64,
		/* tokens extending repetitions beyond this receive penalty int32_t dry_allowed_length =*/
		2,
		/* how many tokens to scan for repetitions(0 = disable penalty, -1 = context size) int32_t dry_penalty_last_n = */
		-1,
		/* dry_sequence_breakers[4]={ "\n", ":", "\"", "*" } */
		4,
		/* samplers[8] */
		8,
		/* grammar = nullptr */
		0,
		/* model_path = nullptr */
		0,
		/* 0 = disabled, 1 = mirostat, 2 = mirostat 2.0 int32_t mirostat =*/
		LCPP_MIROSTAT_NONE,
		/* model family based on file name e.g. deepseek qwen*/
		LCPP_MODEL_FAMILY_UNSPECIFIED,
		/* bool ignore_eos = */
		false,
		/* disable performance metrics bool no_perf = */
		true,
		/* bool timing_per_token = */
		false,
		/* bool grammar_lazy =*/
		false,
		/* default sequence breakers for DRY const char* dry_sequence_breakers[4] =*/
		dry_sequence_breakers,
		/* common_sampler_type samplers[8] =*/
		samplers,
		/* optional BNF-like grammar to constrain sampling char* grammar =*/
		nullptr,
		/* required path to GGUF model file */
		nullptr
	};

	return result;
}

void lcpp_send_abort_signal(bool abort) {
	_abort = abort;
}

bool _ggml_abort_callback(void* data) {
	if (_abort.load()) {
		_abort = false; // reset
		return true;
	}
	return false;
}

void on_new_token(const char* token, int length) {
	if (length > 0) {
		char* text = (char*)std::calloc(length + 1, sizeof(char));
		memcpy(text, token, length);
		uint32_t len = (uint32_t)length;
		TokenStreamCallback(text, &len);
	}
}

void lcpp_set_token_stream_callback(LppTokenStreamCallback_t new_token_callback) {
	TokenStreamCallback = new_token_callback;
}

void lcpp_unset_token_stream_callback() {
	TokenStreamCallback = nullptr;
}

void lcpp_set_chat_message_callback(LppChatMessageCallback_t chat_message_callback) {
	ChatMessageCallback = chat_message_callback;
}

void lcpp_unset_chat_message_callback() {
	ChatMessageCallback = nullptr;
}

static void _set_use_jinja_by_model_family(lcpp_model_family_t model_family) {

	switch (model_family) {
	case LCPP_MODEL_FAMILY_DEEPSEEK:
	case LCPP_MODEL_FAMILY_LLAMA:
	case LCPP_MODEL_FAMILY_MISTRAL:
	case LCPP_MODEL_FAMILY_GRANITE:
	case LCPP_MODEL_FAMILY_GEMMA:
	case LCPP_MODEL_FAMILY_QWEN:
	case LCPP_MODEL_FAMILY_PHI:
		_use_jinja = true;
		break;
	default:
		_use_jinja = false;
		break;
	}
}

static void _set_common_format_by_model_family(lcpp_model_family_t model_family) {
	switch (model_family) {
	case LCPP_MODEL_FAMILY_DEEPSEEK:
	case LCPP_MODEL_FAMILY_QWEN:
		_chat_format = COMMON_CHAT_FORMAT_DEEPSEEK_R1_EXTRACT_REASONING;
		break;
	case LCPP_MODEL_FAMILY_LLAMA:
		_chat_format = COMMON_CHAT_FORMAT_LLAMA_3_X_WITH_BUILTIN_TOOLS;
		break;
	case LCPP_MODEL_FAMILY_MISTRAL:
		_chat_format = COMMON_CHAT_FORMAT_MISTRAL_NEMO;
		break;
	case LCPP_MODEL_FAMILY_GRANITE:
	case LCPP_MODEL_FAMILY_GEMMA:
	case LCPP_MODEL_FAMILY_PHI:
		_chat_format = COMMON_CHAT_FORMAT_GENERIC;
		break;
	default:
		_chat_format = COMMON_CHAT_FORMAT_CONTENT_ONLY;
		break;
	}
}

lcpp_common_chat_msg_t _to_lcpp_common_chat_msg(std::string& response, common_chat_format format) {
	common_chat_msg_t msg = common_chat_parse(response, format);

	lcpp_common_chat_msg_t _msg;
	_msg.n_role = msg.role.length();
	if (_msg.n_role > 0) {
		_msg.role = (char*) std::calloc(_msg.n_role+1, sizeof(char));
		memcpy(_msg.role, msg.role.c_str(), _msg.n_role);
	}
	else {
		_msg.role = nullptr;
	}

	_msg.n_content = msg.content.length();
	if (_msg.n_content > 0) {
		_msg.content = (char*)std::calloc(_msg.n_content + 1, sizeof(char));
		memcpy(_msg.content, msg.content.c_str(), _msg.n_content);
	}
	else {
		_msg.content = nullptr;
	}

	_msg.n_reasoning_content = msg.reasoning_content.length();
	if (_msg.n_reasoning_content > 0) {
		_msg.reasoning_content = (char*)std::calloc(_msg.n_reasoning_content + 1, sizeof(char));
		memcpy(_msg.reasoning_content, msg.reasoning_content.c_str(), _msg.n_reasoning_content);
	}
	else {
		_msg.reasoning_content = nullptr;
	}

	_msg.n_tool_name = msg.tool_name.length();
	if (_msg.n_tool_name > 0) {
		_msg.tool_name = (char*)std::calloc(_msg.n_tool_name + 1, sizeof(char));
		memcpy(_msg.tool_name, msg.tool_name.c_str(), _msg.n_tool_name);
	}
	else {
		_msg.tool_name = nullptr;
	}

	_msg.n_tool_call_id = msg.tool_call_id.length();
	if (_msg.n_tool_call_id > 0) {
		_msg.tool_call_id = (char*)std::calloc(_msg.n_tool_call_id + 1, sizeof(char));
		memcpy(_msg.tool_call_id, msg.tool_call_id.c_str(), _msg.n_tool_call_id);
	}
	else {
		_msg.tool_call_id = nullptr;
	}
	
	if (!msg.content_parts.empty()) {
		std::vector<lcpp_common_chat_msg_content_part_t*> parts(msg.content_parts.size());
		for (auto it = msg.content_parts.cbegin(); it != msg.content_parts.cend(); it++) {
			auto contents = *it;
			lcpp_common_chat_msg_content_part_t part;
			part.n_text = contents.text.size();
			if (part.n_text > 0) {
				part.text = (char*) std::calloc(part.n_text + 1, sizeof(char));
				memcpy(part.text, contents.text.c_str(), part.n_text);
			}
			else {
				part.text = nullptr;
			}

			part.n_type = contents.type.size();
			if (part.n_type > 0) {
				part.type = (char*)std::calloc(part.n_type + 1, sizeof(char));
				memcpy(part.type, contents.text.c_str(), part.n_type);
			}
			else {
				part.type = nullptr;
			}
			parts.push_back(&part);
		}
		_msg.content_parts = parts.data();
		_msg.n_content_parts = parts.size();
	}
	else {
		_msg.content_parts = nullptr;
		_msg.n_content_parts = 0;
	}

	if (!msg.tool_calls.empty()) {
		std::vector<lcpp_common_chat_tool_call_t*> toolcalls(msg.tool_calls.size());
		for (auto it = msg.tool_calls.cbegin(); it != msg.tool_calls.cend(); it++) {
			auto tool_call = *it;
			lcpp_common_chat_tool_call_t toolcall;
			toolcall.n_name = tool_call.name.size();
			if (toolcall.n_name > 0) {
				toolcall.name = (char*)std::calloc(toolcall.n_name + 1, sizeof(char));
				memcpy(toolcall.name, tool_call.name.c_str(), toolcall.n_name);
			}
			else {
				toolcall.name = nullptr;
			}

			toolcall.n_id = tool_call.id.size();
			if (toolcall.n_id > 0) {
				toolcall.id = (char*) std::calloc(toolcall.n_id + 1, sizeof(char));
				memcpy(toolcall.id, tool_call.id.c_str(), toolcall.n_id);
			}
			else {
				toolcall.id = nullptr;
			}

			toolcall.n_arguments = tool_call.arguments.size();
			if (toolcall.n_arguments > 0) {
				toolcall.arguments = (char*)std::calloc(toolcall.n_arguments + 1, sizeof(char));
				memcpy(toolcall.arguments, tool_call.arguments.c_str(), toolcall.n_arguments);
			}
			else {
				toolcall.arguments = nullptr;
			}

			toolcalls.push_back(&toolcall);
		}
		_msg.tool_calls = toolcalls.data();
		_msg.n_tool_calls = toolcalls.size();
	}
	else {
		_msg.tool_calls = nullptr;
		_msg.n_tool_calls = 0;
	}
	return _msg;
}

int _prompt(void* args) {
  lcpp_prompt_args_t* prompt_args = (lcpp_prompt_args_t*)args;
  int n_messages = prompt_args->n_messages;
  const llama_chat_message* messages = prompt_args->messages;
	std::vector<common_chat_msg_t> chat_msgs(n_messages);

	common_chat_msg_t usr_prompt;

	if (n_messages > 0) {
		for (int i = 0; i < n_messages -1; i++) {
			common_chat_msg_t msg;
			msg.role = messages[i].role;
			msg.content = messages[i].content;
			chat_msgs.push_back(msg);
		}

		usr_prompt.role = messages[n_messages - 1].role;
		usr_prompt.content = messages[n_messages - 1].content;
	}

	// helper function to evaluate a prompt and generate a response
	auto generate = [&](const std::string& prompt) {
		std::string response;

		auto ctx = _result.get()->context.get();
		auto model = _result.get()->model.get();
		auto sampler = _sampler.get();
		const bool is_first = llama_get_kv_cache_used_cells(ctx) == 0;

		// tokenize the prompt
		auto _vocab = llama_model_get_vocab(model);
		const int n_prompt_tokens = -llama_tokenize(_vocab, prompt.c_str(), prompt.size(), NULL, 0, is_first, true);
		std::vector<llama_token> prompt_tokens(n_prompt_tokens);
		if (llama_tokenize(_vocab, prompt.c_str(), prompt.size(), prompt_tokens.data(), prompt_tokens.size(), is_first, true) < 0) {
			GGML_ABORT("failed to tokenize the prompt\n");
		}

		// prepare a batch for the prompt
		llama_batch batch = llama_batch_get_one(prompt_tokens.data(), prompt_tokens.size());
		llama_token new_token_id;
		while (true) {
			// check if we have enough space in the context to evaluate this batch
			int n_ctx = llama_n_ctx(ctx);
			int n_ctx_used = llama_get_kv_cache_used_cells(ctx);
			if (n_ctx_used + batch.n_tokens > n_ctx) {
				fprintf(stderr, "context size exceeded\n");
				exit(0);
			}

			if (llama_decode(ctx, batch)) {
				GGML_ABORT("failed to decode\n");
			}

			// sample the next token
			new_token_id = common_sampler_sample(sampler, ctx, -1, false);

			// is it an end of generation?
			if (llama_vocab_is_eog(_vocab, new_token_id)) {
				break;
			}

			// convert the token to a string, print it and add it to the response
			char buf[256];
			int n = llama_token_to_piece(_vocab, new_token_id, buf, sizeof(buf), 0, true);
			if (n < 0) {
				GGML_ABORT("failed to convert token to piece\n");
			}
			std::string piece(buf, n);
			if (TokenStreamCallback != nullptr) {
				on_new_token(buf, n);
			}

			response += piece;

			// prepare the next batch with the sampled token
			batch = llama_batch_get_one(&new_token_id, 1);
		}

		if (ChatMessageCallback != nullptr && !response.empty()) {
			auto chat_msg = _to_lcpp_common_chat_msg(response, (common_chat_format)_chat_format.load());
			auto _response = lcpp_common_chat_msg_ptr(&chat_msg);
			ChatMessageCallback(*_response.get());
		}

		return EXIT_SUCCESS;
	};


	auto chat_add_and_format = [&chat_msgs](const std::string& role, const std::string& content) {
		common_chat_msg new_msg;
		new_msg.role = role;
		new_msg.content = content;
		auto formatted = common_chat_format_single(_chat_templates.get(), chat_msgs, new_msg, role == "user", _use_jinja.load());
		chat_msgs.push_back(new_msg);
		return formatted;
	};

	if (chat_msgs.empty()) {
		// format the system prompt in conversation mode (will use template default if empty)
		if (!_system_prompt.empty()) {
			chat_add_and_format("system", _system_prompt);
		}
	}

	std::string prompt = chat_add_and_format(usr_prompt.role, usr_prompt.content);

	generate(prompt);

	return EXIT_SUCCESS;
}

int lcpp_prompt(const llama_chat_message* messages, int n_messages){
	lcpp_prompt_args_t args;
	args.messages = messages;
	args.n_messages = n_messages;
	thrd_t* thr = NULL;
	thrd_create(thr, _prompt, &args);
  int result = EXIT_SUCCESS;
	thrd_join(*thr,&result);
  return result;
}

static common_params_t _lcpp_params_to_common_params(const llama_model_params_t* model_params, const llama_context_params_t* context_params, const lcpp_params_t* lcpp_params) {
	GGML_ASSERT(lcpp_params->model_path != nullptr);
	common_params_t _c;
	_c.sampling.dry_allowed_length = lcpp_params->dry_allowed_length;
	_c.sampling.dry_base = lcpp_params->dry_base;
	_c.sampling.dry_multiplier = lcpp_params->dry_multiplier;
	_c.sampling.dry_penalty_last_n = lcpp_params->dry_penalty_last_n;
	int n_dry_sequence_breakers = lcpp_params->n_dry_sequence_breakers;
	_c.sampling.dry_sequence_breakers = std::vector<std::string>(n_dry_sequence_breakers);
	for (int i = 0; i < n_dry_sequence_breakers; i++) {
		std::string _value(lcpp_params->dry_sequence_breakers[i]);
		_c.sampling.dry_sequence_breakers.push_back(_value);
	}
	_c.sampling.dynatemp_exponent = lcpp_params->dynatemp_exponent;
	_c.sampling.dynatemp_range = lcpp_params->dynatemp_range;
	if (lcpp_params->n_grammar_length > 0) {
		_c.sampling.grammar = std::string(lcpp_params->grammar);
	}
	_c.sampling.grammar_lazy = lcpp_params->grammar_lazy;
	_c.sampling.ignore_eos = lcpp_params->ignore_eos;
	_c.sampling.min_keep = lcpp_params->min_keep;
	_c.sampling.min_p = lcpp_params->min_p;
	_c.sampling.mirostat = lcpp_params->mirostat;
	_c.sampling.mirostat_eta = lcpp_params->mirostat_eta;
	_c.sampling.mirostat_tau = lcpp_params->mirostat_tau;
	_c.sampling.no_perf = lcpp_params->no_perf;
	_c.sampling.n_prev = lcpp_params->n_prev;
	_c.sampling.n_probs = lcpp_params->n_probs;
	_c.sampling.penalty_freq = lcpp_params->penalty_freq;
	_c.sampling.penalty_last_n = lcpp_params->penalty_last_n;
	_c.sampling.penalty_present = lcpp_params->penalty_present;
	_c.sampling.penalty_repeat = lcpp_params->penalty_repeat;
	int n_samplers = lcpp_params->n_samplers;
	_c.sampling.samplers = std::vector<common_sampler_type>(n_samplers);
	for (int i = 0; i < n_samplers; i++) {
		common_sampler_type _type = (common_sampler_type)lcpp_params->samplers[i];
		_c.sampling.samplers.push_back(_type);
	}
	_c.sampling.seed = lcpp_params->seed;
	_c.sampling.temp = lcpp_params->temp;
	_c.sampling.timing_per_token = lcpp_params->timing_per_token;
	_c.sampling.top_k = lcpp_params->top_k;
	_c.sampling.top_n_sigma = lcpp_params->top_n_sigma;
	_c.sampling.top_p = lcpp_params->top_p;
	_c.sampling.typ_p = lcpp_params->typ_p;
	_c.sampling.xtc_probability = lcpp_params->xtc_probability;
	_c.sampling.xtc_threshold = lcpp_params->xtc_threshold;

	_c.model = std::string(lcpp_params->model_path);
	lcpp_model_family_t _family = lcpp_params->model_family;
	switch (_family) {
	case LCPP_MODEL_FAMILY_LLAMA:
	case LCPP_MODEL_FAMILY_QWEN:
	case LCPP_MODEL_FAMILY_GEMMA:
	case LCPP_MODEL_FAMILY_PHI:
		_c.reasoning_format = COMMON_REASONING_FORMAT_NONE;
		break;
	case LCPP_MODEL_FAMILY_DEEPSEEK:
	case LCPP_MODEL_FAMILY_GRANITE:
		_c.reasoning_format = COMMON_REASONING_FORMAT_DEEPSEEK;
		break;
	default:
		_c.reasoning_format = COMMON_REASONING_FORMAT_NONE;
		break;
	}

	_c.webui = false;
	_c.enable_chat_template = true;
	_c.conversation_mode = COMMON_CONVERSATION_MODE_AUTO;
	_c.cache_type_k = GGML_TYPE_F16;
	_c.cache_type_v = GGML_TYPE_F16;

	if (model_params->devices != NULL) {
		for (auto ptr = model_params->devices; ptr != nullptr; ptr++) {
			_c.devices.push_back(*ptr);
		}
	}

	if (model_params->kv_overrides != NULL) {
		for (auto _ptr = model_params->kv_overrides; _ptr != nullptr; _ptr++)
			_c.kv_overrides.push_back(*_ptr);
	}

	_c.use_mlock = model_params->use_mlock;
	_c.use_mmap = model_params->use_mmap;
	_c.check_tensors = model_params->check_tensors;
	_c.main_gpu = model_params->main_gpu;
	_c.split_mode = model_params->split_mode;
	_c.n_gpu_layers = model_params->n_gpu_layers;

	_c.n_ctx = context_params->n_ctx;
	_c.no_perf = context_params->no_perf;
	_c.n_batch = context_params->n_batch;
	_c.n_ubatch = context_params->n_ubatch;
	_c.rope_freq_base = context_params->rope_freq_base;
	_c.rope_freq_scale = context_params->rope_freq_scale;
	_c.rope_scaling_type = context_params->rope_scaling_type;
	_c.yarn_attn_factor = context_params->yarn_attn_factor;
	_c.yarn_beta_fast = context_params->yarn_beta_fast;
	_c.yarn_beta_slow = context_params->yarn_beta_slow;
	_c.yarn_ext_factor = context_params->yarn_ext_factor;
	_c.yarn_orig_ctx = context_params->yarn_orig_ctx;
	_c.cb_eval = context_params->cb_eval;
	_c.cb_eval_user_data = context_params->cb_eval_user_data;
	_c.embedding = context_params->embeddings;
	_c.flash_attn = context_params->flash_attn;
	_c.display_prompt = false;
	_c.warmup = true;
	// _c.no_kv_offload = !context_params->offload_kqv;
	return _c;
}

void lcpp_reconfigure(const llama_model_params_t model_params, const llama_context_params_t context_params,
	const lcpp_params_t lcpp_params) {
	// only print errors
	llama_log_set([](enum ggml_log_level level, const char* text, void* /* user_data */) {
		if (level >= GGML_LOG_LEVEL_ERROR) {
			fprintf(stderr, "%s", text);
		}
		}, nullptr);

	llama_backend_init();
	auto params = _lcpp_params_to_common_params(&model_params, &context_params, &lcpp_params);
	llama_numa_init(params.numa);
	auto iparams = common_init_from_params(params);
	_result = common_init_result_ptr(&iparams);

	auto model = _result->model.get();

	_chat_templates = common_chat_templates_init(model, params.chat_template);

	_sampler = common_sampler_ptr(common_sampler_init(model, params.sampling));

	if (!params.system_prompt.empty()) {
		_system_prompt = std::string(params.system_prompt.c_str());
	}

	auto ctx = _result->context.get();

	ctx->abort_callback = _ggml_abort_callback;
	
	_set_use_jinja_by_model_family(lcpp_params.model_family);

	_set_common_format_by_model_family(lcpp_params.model_family);
}

int32_t lcpp_tokenize(const char* text, int n_text, bool add_special,
	bool parse_special, llama_token** tokens) {
	auto model = _result.get()->model.get();
	auto _vocab = llama_model_get_vocab(model);
	int32_t n = -llama_tokenize(_vocab, text, n_text, nullptr, 0, add_special, parse_special);

	if (n > 0) {
		*tokens = (llama_token*)std::calloc(n, sizeof(llama_token));
		llama_tokenize(_vocab, text, n_text, *tokens, n, add_special, parse_special);
		return n;
	}
	return 0;
}

void lcpp_detokenize(int* tokens, int n_tokens, bool remove_special, bool   unparse_special,
	lcpp_data_pvalue_t* text) {
	auto model = _result.get()->model.get();
	auto _vocab = llama_model_get_vocab(model);
	int32_t n = -llama_detokenize(_vocab, tokens, n_tokens, nullptr, 0, remove_special, unparse_special);

	if (n > 0) {
		text->found = true;
		text->length = n;
		text->value = (char*)std::calloc(n + 1, sizeof(char));
		llama_detokenize(_vocab, tokens, n_tokens, text->value, n, remove_special, unparse_special);
	}
	else {
		text->found = false;
	}
}

void lcpp_model_description(lcpp_data_pvalue_t* pvalue) {
	auto model = _result.get()->model.get();
	int32_t n = -llama_model_desc(model, nullptr, 0);
	if (n > 0) {
		pvalue->found = true;
		pvalue->length = n;
		pvalue->value = (char*)std::calloc(n + 1, sizeof(char));
		llama_model_desc(model, pvalue->value, n);
	}
	else {
		pvalue->found = false;
	}

}

void lcpp_model_architecture(lcpp_data_pvalue_t* pvalue) {
	auto model = _result.get()->model.get();
	int32_t n = -llama_model_meta_val_str(model, "general.architecture", nullptr, 0);
	if (n > 0) {
		pvalue->found = true;
		pvalue->length = n;
		pvalue->value = (char*)std::calloc(n + 1, sizeof(char));
		llama_model_desc(model, pvalue->value, n);
	}
	else {
		pvalue->found = false;
	}
}

void lcpp_destroy() {
	lcpp_unset_token_stream_callback();
	llama_backend_free();

}

void lcpp_reset(){
	llama_kv_cache_clear(_result.get()->context.get());
}
