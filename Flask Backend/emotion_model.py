#correct emotion app.py

from flask import Flask, request, jsonify
import torch
import torchaudio
import torch.nn as nn
import torch.nn.functional as F
from transformers import Wav2Vec2Model
import pathlib

# Set audio backend for compatibility
torchaudio.set_audio_backend("soundfile")

# ------------------- Emotion Model -------------------
class EmotionRecognitionModel(nn.Module):
    def __init__(self, num_emotions=8):
        super().__init__()
        self.wav2vec2 = Wav2Vec2Model.from_pretrained("facebook/wav2vec2-base")
        for param in self.wav2vec2.parameters():
            param.requires_grad = True
        self.classifier = nn.Sequential(
            nn.Linear(768, 256),
            nn.ReLU(),
            nn.Dropout(0.3),
            nn.Linear(256, num_emotions)
        )

    def forward(self, x):
        outputs = self.wav2vec2(x)
        hidden_states = outputs.last_hidden_state.mean(dim=1)
        logits = self.classifier(hidden_states)
        return logits


class EmotionPredictor:
    def __init__(self, model_path, device=None):
        self.device = torch.device("cuda" if torch.cuda.is_available() else "cpu") if device is None else device
        self.emotion_labels = [
            'neutral', 'calm', 'happy', 'sad',
            'angry', 'fearful', 'disgust', 'surprised'
        ]
        self.model = EmotionRecognitionModel(num_emotions=len(self.emotion_labels)).to(self.device)
        checkpoint = torch.load(model_path, map_location=self.device)
        self.model.load_state_dict(checkpoint['model_state_dict'])
        self.model.eval()
        print(f"Model loaded with validation accuracy: {checkpoint['accuracy']:.4f}")

    def preprocess_audio(self, audio_path):
        audio_path = str(pathlib.Path(audio_path).resolve())
        waveform, sample_rate = torchaudio.load(audio_path)

        if waveform.shape[0] > 1:
            waveform = torch.mean(waveform, dim=0, keepdim=True)
        if sample_rate != 16000:
            resampler = torchaudio.transforms.Resample(orig_freq=sample_rate, new_freq=16000)
            waveform = resampler(waveform)
        max_length = 16000 * 4
        if waveform.shape[1] > max_length:
            waveform = waveform[:, :max_length]
        else:
            waveform = F.pad(waveform, (0, max_length - waveform.shape[1]))
        return waveform.squeeze()

    def predict(self, audio_path):
        waveform = self.preprocess_audio(audio_path).to(self.device)
        with torch.no_grad():
            outputs = self.model(waveform.unsqueeze(0))
            probabilities = F.softmax(outputs, dim=1)
            predicted_idx = torch.argmax(probabilities, dim=1).item()
            confidence = probabilities[0][predicted_idx].item()

        return {
            'emotion': self.emotion_labels[predicted_idx],
            'confidence': confidence,
            'probabilities': {
                emotion: prob.item()
                for emotion, prob in zip(self.emotion_labels, probabilities[0])
            }
        }

