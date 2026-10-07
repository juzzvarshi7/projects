import speech_recognition as sr

recognizer = sr.Recognizer()


def recognize_speech():
    with sr.Microphone() as source:
        print("Listening...")
        audio = recognizer.listen(source)

    try:
        query = recognizer.recognize_google(audio)
        print("You said:", query)
        return query
    except sr.UnknownValueError:
        print("Sorry, I couldn't understand what you said.")
        return None
    except sr.RequestError as e:
        print("Could not request results from Google Speech Recognition service; {0}".format(e))
        return None


while True:
    query = recognize_speech()
    if query:
        if "hello" in query.lower():
            print("Hello! How can I assist you today?")
        elif "weather" in query.lower():
            # Add code to get weather information
            print("Sorry, I can't get weather information yet, but I'm still learning!")
        else:
            print("Sorry, I can't assist you with that yet. How can I improve?")
