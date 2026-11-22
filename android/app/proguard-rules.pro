# google_mlkit_text_recognition references optional recognizers (Chinese, Devanagari,
# Japanese, Korean) that are separate artifacts. The app uses only the Latin one,
# so tell R8 not to fail on the missing classes in release builds.
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
