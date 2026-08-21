# Flutter + MediaPipe LLM inference keep/suppress rules

# Suppress warnings for classes referenced by MediaPipe but not present at compile time
-dontwarn com.google.auto.value.extension.memoized.Memoized
-dontwarn com.google.mediapipe.proto.CalculatorProfileProto$CalculatorProfile
-dontwarn com.google.mediapipe.proto.GraphTemplateProto$CalculatorGraphTemplate

# Keep MediaPipe classes from R8 stripping
-keep class com.google.mediapipe.** { *; }
-keep class com.google.flatbuffers.** { *; }
