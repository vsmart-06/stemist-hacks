from flask import Flask, request
import requests
import os
import dotenv

dotenv.load_dotenv()

app = Flask(__name__)
GOOGLE_API_KEY = os.getenv("GOOGLE_API_KEY")
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")

@app.route("/")
def index():
    return '<marquee direction="right"><h1>The oral-cancer-ml API is up and running!</h1></marquee>'

@app.route("/landmarks", methods = ["GET"])
def landmarks():
    data = request.headers

    latitude = data.get("latitude")
    longitude = data.get("longitude")

    landmarks = requests.get("https://maps.googleapis.com/maps/api/place/nearbysearch/json", params = {"location": f"{latitude},{longitude}", "radius": 5000, "rankby": "prominence", "type": "tourist_attraction", "key": GOOGLE_API_KEY}).json()["results"]

    return {"landmarks": landmarks}

app.run(debug = True)