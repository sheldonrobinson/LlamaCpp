part of 'package:llamacpp/llamacpp.dart';

/// Represents the parameters used for sampling in the model.
class LlamaCppParams {
  /// Do stop on eos
  final bool? ignoreEOS;

  /// disable performance metrics
  final bool? noPerf;

  /// Performance measurement per token
  final bool? timingPerToken;

  /// nNumber of previous tokens to remember
  final int? nPrev;

  /// If greater than 0, output the probabilities of top n_probs tokens.
  final int? nProbs;

  /// Optional seed for random number generation to ensure reproducibility.
  final int? seed;

  /// Limits the number of top candidates considered during sampling.
  final int? topK;

  /// Arguments for top-p sampling (nucleus sampling).
  final double? topP;

  /// Arguments for minimum-p sampling.
  final double? minP;

  /// Arguments for typical-p sampling.
  final double? typicalP;

  final double? top_n_sigma;

  /// The minimum number of items to keep in the sample.
  final int? minKeep;

  /// The temperature value for sampling.
  final double? temperature;

  /// Optional range parameter for temperature adjustment.
  final double? dynaTempRange;

  /// Optional exponent parameter for temperature adjustment.
  final double? dynaTempExponent;

  /// The probability threshold for XTC sampling.
  final double? xtcProbability;

  /// The threshold value for XTC sampling.
  final double? xtcThreshold;

  /// The tau value for Mirostat sampling.
  final double? mirostatTau;

  /// The eta value for Mirostat sampling.
  final double? mirostatEta;

  /// The number of items to keep in the sample.
  final lcpp_mirostat_type? mirostat;

  /// Optional BNF-like grammar for constrained sampling.
  final String? grammar;

  /// Optional BNF-like grammar lazy parsing.
  final bool? grammarLazy;

  /// The number of items to consider for the penalty.
  final int? penaltyLastN;

  /// The penalty for repetition.
  final double? penaltyRepeat;

  /// The penalty frequency.
  final double? penaltyFrequency;

  /// The penalty for present items.
  final double? penaltyPresent;

  /// The multiplier for the penalty.
  final double? dryMultiplier;

  /// The base value for the penalty.
  final double? dryBase;

  /// The maximum allowed length for the sequence.
  final int? dryAllowedLength;

  /// The penalty for the last N items.
  final int? dryPenaltyLastN;

  /// default sequence breakers for DRY
  final List<String>? drySequenceBreakers;

  final List<int>? samplers;

  /// path to GGUF model file
  final String? model_path;

  /// Creates a new instance of [LlamaCppParams].
  const LlamaCppParams(
      {this.ignoreEOS,
      this.noPerf,
      this.timingPerToken,
      this.nPrev,
      this.nProbs,
      this.seed,
      this.topK,
      this.topP,
      this.minP,
      this.typicalP,
      this.top_n_sigma,
      this.minKeep,
      this.temperature,
      this.dynaTempExponent,
      this.dynaTempRange,
      this.xtcProbability,
      this.xtcThreshold,
      this.mirostatTau,
      this.mirostatEta,
      this.mirostat,
      this.grammar,
      this.grammarLazy,
      this.penaltyLastN,
      this.penaltyFrequency,
      this.penaltyRepeat,
      this.penaltyPresent,
      this.dryBase,
      this.dryMultiplier,
      this.dryAllowedLength,
      this.dryPenaltyLastN,
      this.drySequenceBreakers,
      this.samplers,
      this.model_path});

  /// Constructs a [LlamaCppParams] instance from a [Map].
  factory LlamaCppParams.fromMap(Map<String, dynamic> map) => LlamaCppParams(
        ignoreEOS: map['ignore_eos'] ?? false,
        noPerf: map['no_perf'] ?? true,
        timingPerToken: map['timing_per_token'] ?? false,
        nPrev: map['n_prev'] ?? 64,
        nProbs: map['n_probs'] ?? 0,
        seed: map['seed'] ?? LLAMA_DEFAULT_SEED,
        topK: map['top_k'] ?? 40,
        topP: map['top_p'] ?? 0.95,
        minP: map['min_p'] ?? 0.05,
        typicalP: map['typical_p'] ?? 1.0,
        top_n_sigma: map['top_n_sigma'] ?? -1.0,
        minKeep: map['min_keep'] ?? 0,
        temperature: map['temp'] ?? 0.80,
        dynaTempExponent: map['dynatemp_exponent'] ?? 1.0,
        dynaTempRange: map['dynatemp_range'] ?? 0.0,
        xtcProbability: map['xtc_probability'] ?? 0.0,
        xtcThreshold: map['xtc_threshold'] ?? 0.10,
        mirostat: map['mirostat'] ?? 0,
        mirostatTau: map['mirostat_tau'] ?? 5.0,
        mirostatEta: map['mirostat_eta'] ?? 0.1,
        grammar: map['grammar'],
        grammarLazy: map['grammar_lazy'] ?? false,
        penaltyLastN: map['penalty_last_n'] ?? 64,
        penaltyFrequency: map['penalty_freq'] ?? 0.0,
        penaltyRepeat: map['penalty_repeat'] ?? 1.0,
        penaltyPresent: map['penalty_present'] ?? 0.0,
        dryBase: map['dry_base'] ?? 1.75,
        dryMultiplier: map['dry_multiplier'] ?? 0.0,
        dryAllowedLength: map['dry_allowed_length'] ?? 2,
        dryPenaltyLastN: map['dry_penalty_last_n'] ?? -1,
        drySequenceBreakers:
            map['dry_sequence_breakers'],
        samplers: map['samplers'],
        model_path: map['model_path'],
      );

  /// Constructs a [LlamaCppParams] instance from a JSON string.
  factory LlamaCppParams.fromJson(String source) =>
      LlamaCppParams.fromMap(jsonDecode(source));

  /// Converts this instance to a [Pointer<llama_sampler>].
  lcpp_params toNative() {
    final lcpp_params lcppParams = lcpp_sampling_params_defaults();

    if (ignoreEOS != null) {
      lcppParams.ignore_eos = ignoreEOS!;
    }

    if (noPerf != null) {
      lcppParams.no_perf = noPerf!;
    }

    if (timingPerToken != null) {
      lcppParams.timing_per_token = timingPerToken!;
    }

    if (nPrev != null) {
      lcppParams.n_prev = nPrev!;
    }

    if (nProbs != null) {
      lcppParams.n_probs = nProbs!;
    }

    if (seed != null) {
      lcppParams.seed = seed!;
    }

    if (topK != null) {
      lcppParams.top_k = topK!;
    }

    if (topP != null) {
      lcppParams.top_p = topP!;
    }

    if (minKeep != null) {
      lcppParams.min_keep = minKeep!;
    }

    if (minP != null) {
      lcppParams.min_p = minP!;
    }

    if (typicalP != null) {
      lcppParams.typ_p = typicalP!;
    }

    if (top_n_sigma != null) {
      lcppParams.top_n_sigma = top_n_sigma!;
    }

    if (temperature != null) {
      lcppParams.temp = temperature!;
    }

    if (dynaTempExponent != null) {
      lcppParams.dynatemp_exponent = dynaTempExponent!;
    }

    if (dynaTempRange != null) {
      lcppParams.dynatemp_range = dynaTempRange!;
    }

    if (xtcProbability != null) {
      lcppParams.xtc_probability = xtcProbability!;
    }

    if (xtcThreshold != null) {
      lcppParams.xtc_threshold = xtcThreshold!;
    }

    if (mirostat != null) {
      lcppParams.mirostatAsInt = mirostat!.value;
    }

    if (mirostatEta != null) {
      lcppParams.mirostat_eta = mirostatEta!;
    }

    if (mirostatTau != null) {
      lcppParams.mirostat_tau = mirostatTau!;
    }

    if (grammar != null) {
      lcppParams.grammar = grammar!.toNativeUtf8().cast<ffi.Char>();
      lcppParams.n_grammar_length = grammar!.length;
    }

    if (grammarLazy != null) {
      lcppParams.grammar_lazy = grammarLazy!;
    }

    if (penaltyFrequency != null) {
      lcppParams.penalty_freq = penaltyFrequency!;
    }

    if (penaltyLastN != null) {
      lcppParams.penalty_last_n = penaltyLastN!;
    }

    if (penaltyRepeat != null) {
      lcppParams.penalty_repeat = penaltyRepeat!;
    }

    if (penaltyPresent != null) {
      lcppParams.penalty_present = penaltyPresent!;
    }

    if (dryAllowedLength != null) {
      lcppParams.dry_allowed_length = dryAllowedLength!;
    }

    if (dryBase != null) {
      lcppParams.dry_base = dryBase!;
    }

    if (dryMultiplier != null) {
      lcppParams.dry_multiplier = dryMultiplier!;
    }

    if (dryPenaltyLastN != null) {
      lcppParams.dry_penalty_last_n = dryPenaltyLastN!;
    }

    if (drySequenceBreakers != null) {
      if (kDebugMode) {
        print('drySequenceBreakers != null, n=${drySequenceBreakers!.length}');
      }

      // List<ffi.Pointer<ffi.Char>> _breakers = map((str)=>str.toNativeUtf8().cast<ffi.Char>()).toList(growable: false);

      lcppParams.dry_sequence_breakers = ffi.calloc
          .allocate<ffi.Pointer<ffi.Char>>(drySequenceBreakers!.length + 1);

      drySequenceBreakers!.asMap().forEach((idx, str) {
        if (kDebugMode) {
          print('drySequenceBreakers adding, str=${str}');
        }
        lcppParams.dry_sequence_breakers[idx] =
            str.toNativeUtf8().cast<ffi.Char>();
      });
      if (kDebugMode) {
        print('drySequenceBreakers added n=${drySequenceBreakers!.length}');
      }
      lcppParams.dry_sequence_breakers[drySequenceBreakers!.length] =
          ffi.nullptr;
      lcppParams.n_dry_sequence_breakers = drySequenceBreakers!.length;
      if (kDebugMode) {
        print('drySequenceBreakers added, nullptr terminator');
      }
    }

    if (samplers != null) {
      lcppParams.samplers = ffi.calloc<ffi.Uint8>(samplers!.length);

      samplers!.asMap().forEach((idx, str) {
        lcppParams.samplers[idx] = samplers![idx].toUnsigned(8);
      });
      lcppParams.n_samplers = samplers!.length;
    }

    if (model_path != null) {
      lcppParams.model_path = model_path!.toNativeUtf8().cast<ffi.Char>();
      lcppParams.n_model_path_length = model_path!.length;
      String model_file = p.basenameWithoutExtension(model_path!).toLowerCase();
      if (model_file.startsWith('phi')) {
        lcppParams.model_familyAsInt =
            lcpp_model_family.LCPP_MODEL_FAMILY_PHI.value;
      } else if (model_file.startsWith('qwen')) {
        lcppParams.model_familyAsInt =
            lcpp_model_family.LCPP_MODEL_FAMILY_QWEN.value;
      } else if (model_file.startsWith('llama')) {
        lcppParams.model_familyAsInt =
            lcpp_model_family.LCPP_MODEL_FAMILY_LLAMA.value;
      } else if (model_file.startsWith('gemma')) {
        lcppParams.model_familyAsInt =
            lcpp_model_family.LCPP_MODEL_FAMILY_GEMMA.value;
      } else if (model_file.startsWith('deepseek')) {
        lcppParams.model_familyAsInt =
            lcpp_model_family.LCPP_MODEL_FAMILY_DEEPSEEK.value;
      } else if (model_file.startsWith('granite')) {
        lcppParams.model_familyAsInt =
            lcpp_model_family.LCPP_MODEL_FAMILY_GRANITE.value;
      } else {
        lcpp_model_family.LCPP_MODEL_FAMILY_UNSPECIFIED.value;
      }
    }

    return lcppParams;
  }

  /// Converts this instance to a [Map].
  Map<String, dynamic> toMap() => {
        'ignore_eos': ignoreEOS,
        'no_perf': noPerf,
        'timing_per_token': timingPerToken,
        'n_prev': nPrev,
        'n_probs': nProbs,
        'seed': seed,
        'top_k': topK,
        'top_p': topP,
        'min_p': minP,
        'typical_p': typicalP,
        'top_n_sigma': top_n_sigma,
        'min_keep': minKeep,
        'temp': temperature,
        'dynatemp_exponent': dynaTempExponent,
        'dynatemp_range': dynaTempRange,
        'xtc_probability': xtcProbability,
        'xtc_threshold': xtcThreshold,
        'mirostat': mirostat,
        'mirostat_tau': mirostatTau,
        'mirostat_eta': mirostatEta,
        'grammar': grammar,
        'grammar_lazy': grammarLazy,
        'penalty_last_n': penaltyLastN,
        'penalty_freq': penaltyFrequency,
        'penalty_repeat': penaltyRepeat,
        'penalty_present': penaltyPresent,
        'dry_base': dryBase,
        'dry_multiplier': dryMultiplier,
        'dry_allowed_length': dryAllowedLength,
        'dry_penalty_last_n': dryPenaltyLastN,
        'dry_sequence_breakers': drySequenceBreakers,
        'samplers': samplers,
        'model_path': model_path
      };

  /// Converts this instance to a JSON-encoded string.
  String toJson() => jsonEncode(toMap());
}
