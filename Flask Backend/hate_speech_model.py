import re
import speech_recognition as sr

def transcribe_audio(audio_path):
    """Convert WAV audio to text using multi-language recognition"""
    try:
        r = sr.Recognizer()
        with sr.AudioFile(audio_path) as source:
            audio_data = r.record(source)

        languages = ['en-US', 'ur-PK', 'hi-IN']
        best_text = ""
        best_lang = ""

        for lang in languages:
            try:
                text = r.recognize_google(audio_data, language=lang)
                if len(text) > len(best_text):
                    best_text = text
                    best_lang = lang
            except sr.UnknownValueError:
                continue
            except sr.RequestError:
                continue

        return best_text, best_lang.split('-')[0] if best_lang else ""
    except Exception as e:
        print(f"Transcription error: {e}")
        return "", ""

def keyword_match(text, lang, hate_keywords):
    if not text:
        return False

    text_lower = text.lower()
    if lang in hate_keywords:
        for kw in hate_keywords[lang]:
            if kw in text_lower:
                return True

    for kw in hate_keywords.get('roman', []):
        if kw in text_lower:
            return True

    return False

def preprocess_text(text):
    text = text.lower()
    text = re.sub(r"[^a-zA-Z0-9\s]", "", text)
    text = re.sub(r"\s+", " ", text).strip()
    return text

def detect_hate_speech(audio_path, pipeline, hate_keywords):
    result = {
        "transcription": "",
        "language": "unknown",
        "is_hate_speech": 0,
        "confidence": 0.0,
        "error": None
    }

    if not pipeline or not hate_keywords:
        result["error"] = "Model or keywords not loaded"
        return result

    text, lang = transcribe_audio(audio_path)
    if not text:
        result["error"] = "Transcription failed"
        return result

    result["transcription"] = text
    result["language"] = lang or "unknown"

    match = keyword_match(text, lang, hate_keywords)
    clean_text = preprocess_text(text)

    try:
        proba = pipeline.predict_proba([clean_text])[0]
        prediction = pipeline.predict([clean_text])[0]

        is_hate = prediction
        confidence = float(proba[prediction])

        if match and prediction == 0:
            is_hate = 1
            confidence = max(0.6, confidence)

        result["is_hate_speech"] = int(is_hate)
        result["confidence"] = confidence

    except Exception as e:
        result["error"] = f"Prediction error: {e}"
        if match:
            result["is_hate_speech"] = 1
            result["confidence"] = 0.7

    return result