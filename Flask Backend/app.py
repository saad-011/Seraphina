#combined conversion function

import os
import uuid
import tempfile
import torchaudio
import torch.nn as nn
import torch.nn.functional as F
from transformers import Wav2Vec2Model
import subprocess
import numpy as np
import torch
from flask import Flask, request, jsonify
from scipy.io import wavfile
import torchaudio.transforms as T
import pathlib
import pickle
from hate_speech_model import detect_hate_speech
from scream_model import predict_scream
from emotion_model import EmotionPredictor
from scipy.io import wavfile

torchaudio.set_audio_backend("soundfile")
# Load model
MODEL_PATH = "models/hate_speech_model.pkl"
emotion_model = EmotionPredictor(model_path='models/emotion_model.pth')

with open(MODEL_PATH, 'rb') as f:
    model_data = pickle.load(f)

UPLOAD_DIR = 'uploads'
os.makedirs(UPLOAD_DIR, exist_ok=True)

pipeline = model_data['pipeline']
hate_keywords = model_data['hate_keywords']

app = Flask(__name__)
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')

wav_path = None

def convert_audio_to_16k_wav(input_path):
    """Convert any audio format to 16kHz mono WAV and return temp path"""
    
    # Define permanent output path
    output_filename = f"{uuid.uuid4()}_converted.wav"
    output_path = os.path.join("uploads", output_filename)
    
    try:
        subprocess.run([
            'ffmpeg', '-i', input_path, '-ar', '16000', '-ac', '1', '-f', 'wav', output_path
        ], check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        return output_path
    except subprocess.CalledProcessError:
        return None

@app.route('/hateAPI', methods=['POST'])
def hate_speech_detection():
    file = request.files.get('file')
    if not file or file.filename == '':
        return jsonify({'error': 'No file provided'}), 400

    raw_audio_path = os.path.join(tempfile.gettempdir(), f"{uuid.uuid4()}.input")
    try:
        file.save(raw_audio_path)
        global wav_path
        #wav_path = convert_audio_to_16k_wav(raw_audio_path)
        if not wav_path:
            return jsonify({'error': 'Audio conversion failed'}), 500

        result = detect_hate_speech(wav_path, pipeline, hate_keywords)

        # Server-side logging
        print("\n--- Result ---")
        print(f"Transcription : {result['transcription']}")
        print(f"Language      : {result['language']}")
        print(f"Hate Speech   : {result['is_hate_speech']}")
        print(f"Confidence    : {result['confidence']:.2f}")
        if result['error']:
            print(f"Error         : {result['error']}")

        return jsonify({'prediction': int(result['is_hate_speech'])})

    except Exception as e:
        return jsonify({'error': str(e)}), 500

    finally:
        for f in [raw_audio_path, wav_path]:
            try:
                if f and os.path.exists(f):
                    os.remove(f)
            except:
                pass

@app.route('/screamAPI', methods=['POST'])
def scream_detection():
    file = request.files.get('file')
    if not file or file.filename == '':
        return jsonify({'error': 'No file provided'}), 400
    global wav_path
    aac_path = None

    try:
        # Generate a unique AAC file path in the uploads folder
        aac_path = os.path.join("uploads", f"{uuid.uuid4()}.aac")

        file.save(aac_path)
        
        # Convert to 16kHz mono WAV using helper function
        wav_path = convert_audio_to_16k_wav(aac_path)
        if wav_path is None:
            raise RuntimeError("Audio conversion failed")

        # Load WAV file
        sr, audio_np = wavfile.read(wav_path)

        # Normalize
        if audio_np.ndim == 2:  # Redundant, but just in case
            audio_np = audio_np.mean(axis=1)
        if audio_np.dtype == np.int16:
            audio_np = audio_np.astype(np.float32) / 32768.0

        audio_tensor = torch.tensor(audio_np, dtype=torch.float32)

        # No need to resample, already 16kHz
        if audio_tensor.dim() == 1:
            audio_tensor = audio_tensor.unsqueeze(0)

        # Call scream model
        prediction, error = predict_scream(audio_tensor, sr)
        print(f"Prediction for {file.filename}: {prediction}")

        if error:
            return jsonify({'error': error}), 500
                
        return jsonify({'filename': file.filename, 'prediction': prediction})

    except subprocess.CalledProcessError:
        return jsonify({'error': 'FFmpeg conversion failed'}), 500

    except Exception as e:
        return jsonify({'error': str(e)}), 500

    # finally:
    #     for path in [aac_path, wav_path]:
    #         try:
    #             if path and os.path.exists(path):
    #                 os.remove(path)
    #         except:
    #             pass

@app.route("/emotionAPI", methods=["POST"])
def predict_emotion():
    if 'file' not in request.files:
        return jsonify({"error": "No file part in the request"}), 400

    file = request.files['file']
    if file.filename == '':
        return jsonify({"error": "No file selected"}), 400

    # Save AAC file
    aac_path = os.path.join(UPLOAD_DIR, f"{uuid.uuid4()}.aac")
    file.save(aac_path)

    # Convert to WAV
    global wav_path
    if not wav_path:
        return jsonify({"error": "Audio conversion failed"}), 500

    # Run prediction
    try:
        result = emotion_model.predict(wav_path)
        top_emotion = result['emotion']
        print(f"Detected Emotion: {top_emotion}")  # Server log

        alert_emotions = {"fearful", "angry", "disgust"}
        prediction = 1 if top_emotion in alert_emotions else 0

        print(f"Prediction: {prediction}") 
        return jsonify({
            "filename": file.filename,
            "prediction": prediction
        })
    except Exception as e:
        print(f"Prediction error: {e}")
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)