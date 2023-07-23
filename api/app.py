from flask import Flask, request
import requests
import os
import openai
import dotenv
import pymongo
import certifi

dotenv.load_dotenv()

app = Flask(__name__)
GOOGLE_API_KEY = os.getenv("GOOGLE_API_KEY")
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
MONGO_LINK = os.getenv("MONGO_LINK")

class LandmarkChecklist:
    def __init__(self, link: str):
        self.link = link
        self.client = pymongo.MongoClient(link, tlsCAFile = certifi.where())
        self.db = self.client.get_database("stemist_hacks")
        self.table = self.db.get_collection("landmark_checklist")
    
    def add_task(self, username: str, task: list):
        try:
            tasks: list = self.table.find_one({"user": username})["tasks"]
            if tasks:
                tasks.append(task)
            else:
                tasks = [task]
            self.table.update_one({"user": username}, {"$set": {"tasks": tasks}})
        except:
            tasks = [task]
            self.table.insert_one({"user": username, "tasks": tasks})
        
        return True
    
    def update_task(self, username: str, task: list, pressed: bool):
        tasks: list = self.table.find_one({"user": username})["tasks"]
        index = tasks.index([task[0], not pressed])
        tasks[index][1] = pressed
        self.table.update_one({"user": username}, {"$set": {"tasks": tasks}})

        return True

    def get_tasks(self, username: str):
        result = self.table.find_one({"user": username})
        try:
            result = result["tasks"]
        except:
            pass

        return result
    
    def delete_task(self, username: str, task: list):
        tasks: list = self.table.find_one({"user": username})["tasks"]
        tasks.remove(task)
        self.table.update_one({"user": username}, {"$set": {"tasks": tasks}})

        return True

@app.route("/")
def index():
    return '<marquee direction="right"><h1>The tourio API is up and running!</h1></marquee>'

@app.route("/landmarks", methods = ["GET"])
def landmarks():
    data = request.headers

    latitude = data.get("latitude")
    longitude = data.get("longitude")
    if not (latitude and longitude):
        place = data.get("place")
        location = requests.get("https://maps.googleapis.com/maps/api/place/findplacefromtext/json", params = {"input": place, "inputtype": "textquery", "fields": "geometry", "key": GOOGLE_API_KEY}).json()["candidates"][0]["geometry"]["location"]
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

@app.route("/city-details", methods = ["GET"])
def city_details():
    data = request.headers

    latitude = data.get("latitude")
    longitude = data.get("longitude")

    response = requests.get("https://maps.googleapis.com/maps/api/geocode/json", params = {"latlng": f"{latitude},{longitude}", "result_type": "locality", "key": GOOGLE_API_KEY}).json()["results"][0]["address_components"]

    for x in response:
        if "locality" in x["types"]:
            city = x["long_name"]
            break

    gpt_response = openai.ChatCompletion.create(
    model = "gpt-3.5-turbo",
    messages = [
        {"role": "user", "content": f"Provide information on {city} as if you are a tour guide speaking to a tourist. You don't have to introduce yourself."}
        ]
    )
    decoded_response = gpt_response['choices'][0]['message']['content']
    
    return {"city": city, "details": decoded_response}

@app.route("/add-task", methods = ["POST"])
def add_task():
    data = request.form

    username = data.get("user")
    task = eval(data.get("task"))

    mongo = LandmarkChecklist(MONGO_LINK)

    mongo.add_task(username, task)

    return {"message": "Task added successfully"}

@app.route("/update-task", methods = ["PATCH"])
def update_task():
    data = request.headers

    username = data.get("user")
    task = eval(data.get("task"))
    pressed = eval(data.get("pressed"))

    mongo = LandmarkChecklist(MONGO_LINK)

    mongo.update_task(username, task, pressed)

    return {"message": "Task updated successfully"}

@app.route("/get-tasks", methods = ["GET"])
def get_tasks():
    data = request.headers

    username = data.get("user")

    mongo = LandmarkChecklist(MONGO_LINK)

    tasks = mongo.get_tasks(username)

    return {"tasks": tasks}

@app.route("/delete-task", methods = ["DELETE"])
def delete_task():
    data = request.headers

    username = data.get("user")
    task = eval(data.get("task"))
    mongo = LandmarkChecklist(MONGO_LINK)

    mongo.delete_task(username, task)

    return {"message": "Task deleted successfully"}

if __name__ == "__main__":
    app.run(debug=True)