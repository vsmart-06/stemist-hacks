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

    try:
        latitude = data.get("latitude")
        longitude = data.get("longitude")
    except:
        place = data.get("place")
        location = requests.get("https://maps.googleapis.com/maps/api/place/findplacefromtext/json", params = {"input": place}).json()["candidates"][0]["geometry"]["location"]
        latitude = location["lat"]
        longitude = location["lng"]

    landmarks = requests.get("https://maps.googleapis.com/maps/api/place/nearbysearch/json", params = {"location": f"{latitude},{longitude}", "radius": 5000, "rankby": "prominence", "type": "tourist_attraction", "key": GOOGLE_API_KEY}).json()["results"]

    landmarks = [{"name": landmark["name"], "vicinity": landmark["vicinity"]} for landmark in landmarks]

    return {"landmarks": landmarks}

openai.api_key = OPENAI_API_KEY

@app.route("/details", methods = ["GET"])
def details():
    data = request.headers
    landmark = data.get('landmark')
    response = openai.ChatCompletion.create(
    model = "gpt-3.5-turbo",
    messages = [
        {"role": "user", "content": f"Provide information on {landmark} as if you are a tour guide speaking to a tourist. You don't have to introduce yourself."}
        ]
    )
    decoded_response = response['choices'][0]['message']['content']
    return {"details": decoded_response}

@app.route("/autocomplete", methods = ["GET"])
def autocomplete():
    data = request.headers
    place = data.get("place")

    options = requests.get("https://maps.googleapis.com/maps/api/place/autocomplete/json", params = {"input": place, "key": GOOGLE_API_KEY}).json()["predictions"]

    options = [option["description"] for option in options]

    return {"autocomplete": options}