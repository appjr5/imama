import 'dart:io';
import 'package:flutter_gemma/flutter_gemma.dart';

/// Runs Gemma directly on the phone via flutter_gemma (MediaPipe/LiteRT).
/// No server, no internet after the first model load.
///
/// IMPORTANT: flutter_gemma's API changes fairly often between versions.
/// Cross-check this against the package's example app / pub.dev page for
/// your installed version before relying on it.
class GemmaService {
  static InferenceModel? _model;
  static InferenceChat? _chat;

  /// Swahili Gemma 1B (fine-tuned by Crane AI Labs), placed in the
  /// project's model/ folder (declared under flutter: assets: in
  /// pubspec.yaml). Text-only — no image support, output is Swahili-only.
  /// Source: https://huggingface.co/CraneAILabs/swahili-gemma-1b-litert
  static const String _modelAssetPath = 'model/swahili-gemma-1b-fp16-instruct.task';

  static bool get isReady => _model != null && _chat != null;

  /// Loads the bundled model (if not already loaded).
  static Future<void> ensureModelReady() async {
    if (isReady) return;

    await FlutterGemma.installModel(modelType: ModelType.gemmaIt)
        .fromAsset(_modelAssetPath)
        .install();

    _model = await FlutterGemma.getActiveModel(maxTokens: 2048);
    // supportImage: false — Swahili Gemma 1B is text-only.
    _chat = await _model!.createChat(supportImage: false);
  }

  /// Sends a message to the on-device model. Note: this model is
  /// text-only — the [image] parameter is accepted for API compatibility
  /// with the old ApiService, but throws if actually passed.
  static Future<String> sendChatMessage({
    required String message,
    File? image,
  }) async {
    await ensureModelReady();

    if (image != null) {
      throw Exception(
          'Msaidizi huyu hatoi picha kwa sasa — tuma ujumbe wa maandishi pekee.');
    }

    await _chat!.addQueryChunk(Message.text(text: message, isUser: true));

    final response = await _chat!.generateChatResponse();
    // ModelResponse is a sealed type: TextResponse (.token),
    // ThinkingResponse (.content), FunctionCallResponse (.name/.args).
    // We only expect plain text back from this simple chat setup.
    if (response is TextResponse) {
      return _cleanReply(response.token);
    }
    // Fallback for any other response shape — shouldn't normally hit this
    // with a plain text-only model and no tools/thinking mode enabled.
    return _cleanReply(response.toString());
  }

  static String _cleanReply(String text) {
    return text
        .replaceAll('<end_of_turn>', '')
        .replaceAll('<start_of_turn>', '')
        .trim();
  }

  static Future<bool> ping() async => isReady;

  static Future<void> dispose() async {
    await _model?.close();
    _model = null;
    _chat = null;
  }
}