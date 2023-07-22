from flask import Flask, request

app = Flask(__name__)

@app.route("/")
def index():
    return '<marquee direction="right"><h1>The oral-cancer-ml API is up and running!</h1></marquee>'

app.run(debug = True)