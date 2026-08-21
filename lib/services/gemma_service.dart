import 'package:flutter/foundation.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'rag_service.dart';

enum GemmaState { idle, installing, ready, error }

class GemmaService {
  static InferenceModel? _model;
  static InferenceChat? _chat;

  static final ValueNotifier<GemmaState> state = ValueNotifier(GemmaState.idle);
  static final ValueNotifier<int> installProgress = ValueNotifier(0);
  static String? lastError;

  static const String _modelAssetPath = 'model/swahili-gemma-1b-fp16-instruct.task';
static bool get isReady => state.value == GemmaState.ready;

  static Future<void> ensureModelReady() async {
    if (isReady) return;
    if (state.value == GemmaState.installing) {
      // Already installing — wait for it to finish
      await Future.doWhile(() async {
        await Future.delayed(const Duration(milliseconds: 200));
        return state.value == GemmaState.installing;
      });
      if (!isReady) throw Exception(lastError ?? 'Mfano haukuweza kupakia.');
      return;
    }

    state.value = GemmaState.installing;
    installProgress.value = 0;
    lastError = null;

    try {
      // installModel must always be called — it registers the active model spec
      // that getActiveModel() depends on, even when the files are already cached.
      await FlutterGemma.installModel(modelType: ModelType.gemmaIt)
          .fromAsset(_modelAssetPath)
          .withProgress((p) => installProgress.value = p)
          .install();

      _model = await FlutterGemma.getActiveModel(maxTokens: 1024);
      _chat = await _model!.createChat(
        supportImage: false,
        systemInstruction:
            'Wewe ni msaidizi wa afya kwa mama wajawazito. Ongea Kiswahili pekee. '
            'Toa majibu mafupi, sahihi, na yenye huruma. '
            'Kwa dalili za dharura, mwambie mtumiaji aende hospitali mara moja.',
      );

      state.value = GemmaState.ready;
      // Load RAG knowledge base in background (non-blocking)
      RagService.ensureLoaded().ignore();
    } catch (e) {
      lastError = e.toString();
      state.value = GemmaState.error;
      rethrow;
    }
  }

  static Future<String> sendChatMessage({required String message}) async {
    if (!isReady) await ensureModelReady();

    // Augment the message with retrieved context if available
    final context = RagService.retrieve(message);
    final augmented = context.isNotEmpty
        ? '$context\n\nSwali la mtumiaji: $message'
        : message;

    await _chat!.addQueryChunk(Message.text(text: augmented, isUser: true));
    final response = await _chat!.generateChatResponse();

    final text = response is TextResponse ? response.token : response.toString();
    return _clean(text);
  }

  static String _clean(String text) => text
      .replaceAll('<end_of_turn>', '')
      .replaceAll('<start_of_turn>', '')
      .trim();

  static Future<void> dispose() async {
    await _model?.close();
    _model = null;
    _chat = null;
    state.value = GemmaState.idle;
  }
}
