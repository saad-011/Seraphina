import os
import uuid
import torch
import tempfile
from PIL import Image
import matplotlib.pyplot as plt
from torchvision import transforms
import torchaudio.transforms as T

device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')

# Load scream model once
scream_model = torch.load('models/scream_model.pt', weights_only=False, map_location=device)
scream_model = scream_model.to(device)
scream_model.eval()

# Image transform
transform = transforms.Compose([
    transforms.Resize((64, 862)),
    transforms.ToTensor(),
    transforms.Lambda(lambda x: x[:3, :, :])
])

def transform_to_spectrogram_image(audio_tensor, sample_rate):
    mel_spec = T.MelSpectrogram(
        sample_rate=sample_rate,
        n_fft=1024,
        hop_length=512,
        n_mels=64
    )(audio_tensor)

    log_mel_spec = torch.log(mel_spec + 1e-10)
    log_mel_spec = log_mel_spec.squeeze().numpy()

    image_path = os.path.join(tempfile.gettempdir(), f'{uuid.uuid4()}.png')
    plt.imsave(image_path, log_mel_spec, cmap='viridis')
    return image_path

def predict_scream(audio_tensor, sample_rate):
    image_path = None
    try:
        # Convert to mel spectrogram image
        image_path = transform_to_spectrogram_image(audio_tensor, sample_rate)
        image = Image.open(image_path).convert("RGB")
        image_tensor = transform(image).unsqueeze(0).to(device)

        with torch.no_grad():
            output = scream_model(image_tensor)
            prediction = output.argmax(dim=1).item()

        return prediction, None

    except Exception as e:
        return None, str(e)

    finally:
        if image_path and os.path.exists(image_path):
            os.remove(image_path)