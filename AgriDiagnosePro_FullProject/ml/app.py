# ml/app.py
from fastapi import FastAPI
from pydantic import BaseModel
import ml.demo_model as demo

class Img(BaseModel):
    image: str

app = FastAPI()

@app.post('/ml/predict')
async def predict(payload: Img):
    # payload.image is base64
    res = demo.predict_from_b64(payload.image)
    return res

# Run: uvicorn app:app --host 0.0.0.0 --port 8000
