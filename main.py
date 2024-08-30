from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
from transformers import AutoTokenizer, AutoModelForSeq2SeqLM, pipeline
import uvicorn

app = FastAPI()

# Load the model and tokenizer from the local directory
model = AutoModelForSeq2SeqLM.from_pretrained("./models/flan-t5-small")
tokenizer = AutoTokenizer.from_pretrained("./models/flan-t5-small")

pipe_flan = pipeline("text2text-generation", model=model, tokenizer=tokenizer)

@app.get("/infer_t5")
def t5(input):
    output = pipe_flan(input)
    return {"output": output[0]["generated_text"]}

app.mount("/", StaticFiles(directory="static", html=True), name="static")

@app.get("/")
def index() -> FileResponse:
    return FileResponse(path="/app/static/index.html", media_type="text/html")

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=7860)