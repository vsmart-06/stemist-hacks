# Tourio

### This is our submission for STEMist Hacks 2.0

### Team members:

- [Nalin Mathur](https://github.com/DrSnek)
- [Srivishnu Vusirikala](https://github.com/vsmart-06)
- [Vishaal Iyer](https://github.com/EmperorMonke)

### Technologies:

- Flutter
- Python
- MongoDB

### Idea:

- [x] The app takes the IP address of the user and finds the nearest landmarks

- [x] Displays the landmarks and asks user to choose some to visit

- [x] Marks the most popular landmarks to give users an idea of good places to visit

- [x] Tells the user what the city is famous for

- [x] Utilises ChatGPT to generate details about the location to present to the user

- [x] Provides an option to allow users to explore other places even if they are not at the location

- [x] Merges map-based choosing along with location search

- [x] When you are in a place, it allows users to create their own checklist with different places to visit and check them off when visited

### Installation:

- Create a `.env` file in the project's root directory, and in the file, add the following credentials:
```console
GOOGLE_API_KEY = "<your google api key>"
OPENAI_API_KEY = "<your openai api key>"
MONGO_LINK = "<the connection string to your mongodb cluster>"
```

- Navigate into the `api` directory with the following command:
```console
cd api
```

- **Optional:** If you would like to use a Python virtual environment for the next step, run the following commands:

    - Windows:

    ```console
    pip install venv
    python3 -m venv .venv
    .venv\Scripts\activate
    ```

    - MacOS/Linux:

    ```console
    pip install venv
    python3 -m venv .venv
    . .venv/bin/activate
    ```

- Run the following commands to start the API:
```console
pip install -r requirements.txt
flask run
```

- Start the Flutter app with the following command:
```console
cd ..
cd src
flutter run --dart-define GOOGLE_API_KEY=<your google api key>
```