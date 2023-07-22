from flask import Flask, request
import requests
import os
import openai

app = Flask(__name__)
GOOGLE_API_KEY = os.getenv("GOOGLE_API_KEY")
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")

@app.route("/")
def index():
    return '<marquee direction="right"><h1>The tourio API is up and running!</h1></marquee>'

@app.route("/landmarks", methods = ["GET"])
def landmarks():
    data = request.headers

    latitude = data.get("latitude")
    longitude = data.get("longitude")

    landmarks = requests.get("https://maps.googleapis.com/maps/api/place/nearbysearch/json", params = {"location": f"{latitude},{longitude}", "radius": 5000, "rankby": "prominence", "type": "tourist_attraction", "key": GOOGLE_API_KEY}).json()["results"]

    return {"landmarks": landmarks}

openai.api_key = OPENAI_API_KEY

@app.route("/details")
def details():
    data = request.headers
    landmark = data.get('landmark')
    response = openai.ChatCompletion.create(
    model = "gpt-3.5-turbo",
    messages = [
        {"role": "user", "content": f"Provide information on {landmark} as if you are a tour guide speaking to a tourist. You don't have to introduce yourself."}
        ]
    )
    decoded_response = response.response['choices'][0]['message']['content']
    return {"details": decoded_response}