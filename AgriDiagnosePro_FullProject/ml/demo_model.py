# ml/demo_model.py
# Simple deterministic 'model' for demo/testing: checks average brightness
from PIL import Image
import io
import base64

def predict_from_b64(b64str):
    data = base64.b64decode(b64str)
    img = Image.open(io.BytesIO(data)).convert('L').resize((64,64))
    arr = list(img.getdata())
    avg = sum(arr)/len(arr)
    # deterministic mapping
    if avg < 85:
        return {'class': 'Leaf Spot', 'confidence': 0.78}
    elif avg < 150:
        return {'class': 'Rust', 'confidence': 0.65}
    else:
        return {'class': 'Healthy', 'confidence': 0.9}
