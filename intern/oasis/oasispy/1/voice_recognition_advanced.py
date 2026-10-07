import speech_recognition as sr
import pyttsx3
import spacy
import wikipedia

recognizer = sr.Recognizer()
engine = pyttsx3.init()
nlp = spacy.load("en_core_web_sm")

def recognize_speech():
    with sr.Microphone() as source:
        print("Listening..")
        audio = recognizer.listen(source)
    try:
        query = recognizer.recognize_google(audio)
        print("You said: ", query)
        return query
    except sr.UnknownValueError:
        print("Sorry, I couldn't understand what you said.")
        return None
    except sr.RequestError as e:
        print("Could not request results from Google Speech Recognition service; {0}".format(e))
        return None

def speak(text):
    engine.say(text)
    engine.runAndWait()

def search_wikipedia(query):
    try:
        summary=wikipedia.summary(query, sentences=2)
        return summary
    except wikipedia.exceptions.DisambiguationError as e:
        options = e.options
        return f"Multiple options found. Please specify: {', '.join(options)}"
    except wikipedia.exceptions.PageError:
        return "Sorry, I could not find information on that topic."
                    

# Define a dictionary to store user preferences
user_preferences = {
    'language': 'en',  # Default language
    'voice_speed': 'medium'  # Default voice speed
}

# Function to update user preferences
def update_preferences(setting, value):
    user_preferences[setting] = value

# Main loop
while True:
    query = recognize_speech()
    if query:
        if "exit" in query.lower():
            speak("Goodbye!")
            break
        doc = nlp(query)
        for token in doc:
            if token.text.lower() == 'customize':
                speak("What setting would you like to customize?")
                setting = recognize_speech().lower()
                speak("What value would you like to set?")
                value = recognize_speech().lower()
                update_preferences(setting, value)
                speak(f"Preference for {setting} updated to {value}.")
            else:
                response = search_wikipedia(query)
                speak(response)
                break