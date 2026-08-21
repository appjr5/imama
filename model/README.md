---
base_model: CraneAILabs/swahili-gemma-1b
language:
- en
- sw
library_name: litert
license: gemma
tags:
- swahili
- translation
- conversational
- gemma
- gemma3
- fine-tuned
- litert
- mobile
- android
- ios
- mediapipe
- edge
- on-device
- swahili
- translation
- conversational
- gemma
- gemma3
- fine-tuned
- litert
- mobile
- android
- ios
- mediapipe
pipeline_tag: text-generation
---
# Swahili Gemma 1B - LiteRT

LiteRT (formerly TensorFlow Lite) optimized version of **Swahili Gemma 1B** - a fine-tuned Gemma 3 1B instruction model specialized for **English-to-Swahili translation and Swahili conversational AI**. 

This repository contains MediaPipe task bundles optimized for mobile deployment on Android and iOS devices.

## 📊 Translation Performance

![Translation Performance Comparison](swahili_gemma_ascending_chart.png)

### FLORES-200 Evaluation Results

Our Swahili Gemma 1B model demonstrates strong performance in English-to-Swahili translation:

| Metric | Score | Ranking |
|--------|-------|---------|
| **BLEU** | **27.6** | 4th out of 5 models |
| **chrF++** | **56.8** | 4th out of 5 models |

### Model Comparison

| Model | Parameters | BLEU | chrF++ | Efficiency* |
|-------|------------|------|--------|-------------|
| Gemma 3 4B | 4B | 10.9 | 44.1 | 2.7 |
| **Swahili Gemma 1B** | **1B** | **27.6** | **56.8** | **27.6** |
| Gemma 3 27B | 27B | 29.4 | 60.0 | 1.1 |
| GPT-5 Mini | ~8B | 31.8 | 62.4 | 4.0 |
| Gemini 2.0 Flash | Large | 35.6 | 64.6 | N/A |

*Efficiency = BLEU Score / Parameters (in billions)

### Key Performance Insights

🎯 **Efficiency Leader**: Achieves the highest BLEU-to-parameter ratio (27.6 BLEU per billion parameters)  
🚀 **Size Advantage**: Outperforms Gemma 3 4B (4x larger) by 153% on BLEU score  
💎 **Competitive Quality**: Achieves 94% of Gemma 3 27B performance with 27x fewer parameters  
⚡ **Practical Deployment**: Runs efficiently on consumer hardware while maintaining quality  

### Evaluation Details

- **Dataset**: FLORES-200 English→Swahili (1,012 translation pairs)
- **Metrics**: BLEU (bilingual evaluation understudy) and chrF++ (character F-score)
- **Evaluation**: Zero-shot translation performance
- **Model**: swahili-gemma-1b-it-33000 checkpoint

## 📱 Available Models

| File | Size | Quantization | Use Case |
|------|------|--------------|----------|
| `swahili-gemma-1b-fp16-instruct.task` | ~1.0GB | FP16 | **Recommended** - Instruction following format with MediaPipe bundling |
| `swahili-gemma-1b-fp16-raw.tflite` | ~1.0GB | FP16 | Raw TFLite model - requires custom tokenizer integration |

## 🚀 Quick Start

### Android (MediaPipe)

```kotlin
import com.google.mediapipe.tasks.genai.llminference.LlmInference

// Load the model
val options = LlmInference.LlmInferenceOptions.builder()
    .setModelPath("/path/to/swahili-gemma-1b-fp16-instruct.task")
    .build()

val llmInference = LlmInference.createFromOptions(context, options)

// Generate response
val response = llmInference.generateResponse("Translate to Swahili: Good morning")
println(response)
```

### iOS (MediaPipe)

```swift
import MediaPipeTasksGenAI

// Load the model
let options = LlmInference.Options()
options.modelPath = "/path/to/swahili-gemma-1b-fp16-instruct.task"

let llmInference = try LlmInference(options: options)

// Generate response
let response = try llmInference.generateResponse(inputText: "Translate to Swahili: Good morning")
print(response)
```

### Web (MediaPipe)

```javascript
import { LlmInference } from '@mediapipe/tasks-genai';

const llm = await LlmInference.createFromModelPath(
  '/path/to/swahili-gemma-1b-fp16-instruct.task'
);

const response = await llm.generateResponse('Translate to Swahili: Good morning');
console.log(response);
```

## 🌍 Language Capabilities

- **Input Languages**: English + Swahili
- **Output Language**: Swahili only
- **Primary Focus**: English-to-Swahili translation and Swahili conversation

## 📊 Performance Metrics

### Translation Quality (BLEU Scores)

| Model | BLEU Score | chrF++ |
|-------|------------|--------|
| **🥇 Swahili Gemma 1B** | **23.64** | **52.26** |
| 🥈 ChatGPT-4o-latest | [TBD] | [TBD] |
| 🥉 Other Models | [TBD] | [TBD] |

*Evaluated on 1,012 English-to-Swahili translation samples.*

## 📦 Model Variants Guide

### 1. `swahili-gemma-1b-fp16-instruct.task` (RECOMMENDED)

**Best for**: Most mobile applications - ready-to-use MediaPipe bundle

**Input format**: Natural instructions
```
Translate to Swahili: Hello, how are you?
```

**MediaPipe formats as**: 
```
### Instruction:
Translate to Swahili: Hello, how are you?

### Response:
```

### 2. `swahili-gemma-1b-fp16-raw.tflite`

**Best for**: Custom integrations requiring direct TFLite model access

**Requirements**: You need to handle tokenization manually
**Use case**: Advanced users who want to integrate with custom tokenizers or frameworks

## 🎯 Capabilities

- **Translation**: English-to-Swahili translation
- **Conversational AI**: Natural dialogue in Swahili
- **Summarization**: Text summarization in Swahili
- **Writing**: Creative and informational writing in Swahili
- **Question Answering**: General knowledge responses in Swahili

## 💡 Generation Parameters

Optimal settings for mobile deployment:

```javascript
// JavaScript/Web
const response = await llm.generateResponse(prompt, {
  temperature: 0.3,
  topK: 40,
  randomSeed: 42
});
```

```kotlin
// Android
val response = llmInference.generateResponse(
    inputText = prompt,
    temperature = 0.3f,
    topK = 40,
    randomSeed = 42
)
```

```swift
// iOS
let options = LlmInference.Options()
options.temperature = 0.3
options.topK = 40
options.randomSeed = 42

let response = try llmInference.generateResponse(
    inputText: prompt,
    options: options
)
```

## 📱 Mobile Integration

### Memory Requirements
- **RAM**: Minimum 3GB recommended for optimal performance
- **Storage**: ~1.2GB per task bundle
- **CPU**: ARMv8 or newer recommended

### Performance Tips
1. **Preload models** during app initialization
2. **Use appropriate quantization**: FP16 provides good quality for mobile
3. **Cache responses** for repeated queries
4. **Batch processing** for multiple translations

## 🔗 Related Models

- **Original Model**: [CraneAILabs/swahili-gemma-1b](https://huggingface.co/CraneAILabs/swahili-gemma-1b) - Full precision HuggingFace model
- **GGUF Quantizations**: [CraneAILabs/swahili-gemma-1b-GGUF](https://huggingface.co/CraneAILabs/swahili-gemma-1b-GGUF) - Optimized for llama.cpp/Ollama
- **Ollama**: [crane-ai-labs/swahili-gemma-1b](https://ollama.com/crane-ai-labs/swahili-gemma-1b) - Ready-to-run with Ollama

## 🎨 Use Cases

- **Mobile Translation Apps**: Offline English-Swahili translation
- **Language Learning**: Practice Swahili with instant feedback
- **Cultural Apps**: Create culturally aware Swahili content
- **Educational Tools**: Swahili learning assistants for mobile
- **Offline AI**: No internet required after model download
- **Edge Computing**: Run AI locally on mobile devices

## ⚠️ Limitations

- **Language Output**: Responds only in Swahili
- **Mobile Resources**: Requires significant RAM and storage
- **Context Length**: Optimized for shorter inputs on mobile
- **Quantization**: FP16 requires more memory than INT4/INT8
- **Platform Support**: Requires MediaPipe Tasks GenAI support

## 🛠️ Development Setup

### Android
```gradle
dependencies {
    implementation 'com.google.mediapipe:tasks-genai:latest.release'
}
```

### iOS
```swift
// Add to Package.swift
.package(url: "https://github.com/google/mediapipe", from: "0.10.0")
```

### Web
```bash
npm install @mediapipe/tasks-genai
```

## 📄 License

This model is released under the [Gemma Terms of Use](https://ai.google.dev/gemma/terms). Please review the terms before use.

## 🙏 Acknowledgments

- **Google**: For the Gemma 3 base model, support and guidance.
- **Community**: For Swahili language resources and datasets
- **Gilbert Korir (Msingi AI, Nairobi, Kenya)**
- **Alfred Malengo Kondoro (Hanyang University, Seoul, South Korea)**

## Citation

If you use these LiteRT models in your research or mobile applications, please cite:

```bibtex
@misc{crane_ai_labs_2025,
    author    = {Bakunga Bronson and Kato Steven Mubiru and Lwanga Caleb and Gimei Alex and Kavuma Lameck and Roland Ganafa and Sibomana Glorry and Atuhaire Collins and JohnRoy Nangeso and Tukamushaba Catherine},
    title     = {Swahili Gemma: A Fine-tuned Gemma 3 1B Model for Swahili conversational AI},
    year      = {2025},
    url       = {https://huggingface.co/CraneAILabs/swahili-gemma-1b},
    organization = {Crane AI Labs}
}
```

---

**Built with ❤️ by Crane AI Labs**

*Swahili Gemma - Your helpful Swahili AI companion, now on mobile!*