import speech_recognition as sr
import pyttsx3
import spacy
import requests
import feedparser
import webbrowser
import wikipedia

# Initialize speech recognition
recognizer = sr.Recognizer()

# Initialize text-to-speech engine
engine = pyttsx3.init()

# Initialize spaCy NLP model
nlp = spacy.load("en_core_web_sm")

# OpenWeatherMap API key
weather_api_key = "916e3edbc3679db39f5cdb6ed42b5d66"

# News API key
news_api_key = "c76e86f226384717bb4ae749f1753d2c"

# Function to recognize speech
def recognize_speech():
    with sr.Microphone() as source:
        print("Listening...")
        audio = recognizer.listen(source)

    try:
        # Recognize speech
        query = recognizer.recognize_google(audio)
        print("You said:", query)
        return query
    except sr.UnknownValueError:
        print("Sorry, I couldn't understand what you said.")
        return None
    except sr.RequestError as e:
        print("Could not request results from Google Speech Recognition service; {0}".format(e))
        return None

# Function to speak text
def speak(text):
    engine.say(text)
    engine.runAndWait()
    print(text)

# Function to get weather updates
def get_weather(city):
    url = f"http://api.openweathermap.org/data/2.5/weather?q={city}&appid={weather_api_key}"
    response = requests.get(url)
    if response.status_code == 200:
        data = response.json()
        weather_description = data['weather'][0]['description']
        temperature = data['main']['temp']
        temperature_celsius = round(temperature - 273.15, 2)
        return f"The weather in {city} is {weather_description} with a temperature of {temperature_celsius} degrees Celsius."
    else:
        return "Sorry, I couldn't fetch the weather information at the moment."

# Function to get latest news headlines
def get_news(query):
    url = f"https://newsapi.org/v2/everything?q={query}&apiKey={news_api_key}"
    response = requests.get(url)
    if response.status_code == 200:
        data = response.json()
        headlines = [article['title'] for article in data['articles']]
        return "Here are the latest news headlines:\n" + "\n".join(headlines)
    else:
        return "Sorry, I couldn't fetch the news headlines at the moment."

# Function to get RSS feed headlines
def get_rss_feed(url):
    feed = feedparser.parse(url)
    if feed.entries:
        headlines = [entry.title for entry in feed.entries]
        return "Here are the latest headlines from the RSS feed:\n" + "\n".join(headlines)
    else:
        return "Sorry, I couldn't fetch the headlines from the RSS feed."

# Function to search Google
def search_google(query):
    search_url = f"https://www.google.com/search?q={query}"
    webbrowser.open(search_url)

# Function to search Wikipedia
def search_wikipedia(query):
    try:
        summary = wikipedia.summary(query, sentences=2)
        return summary
    except wikipedia.exceptions.DisambiguationError as e:
        options = e.options
        return f"Multiple options found. Please specify: {', '.join(options)}"
    except wikipedia.exceptions.PageError:
        return "Sorry, I couldn't find information on that topic."

# Main loop
while True:
    query = recognize_speech()
    if query:
        doc = nlp(query)
        for token in doc:
            if token.text.lower() == 'weather':
                city = ""
                for ent in doc.ents:
                    if ent.label_ == "GPE":
                        city = ent.text
                        break
                if city:
                    weather_info = get_weather(city)
                    speak(weather_info)
                else:
                    speak("Please specify a city.")
            elif token.text.lower() == 'news':
                news_headlines = get_news("coronavirus")
                speak(news_headlines)
            elif token.text.lower() == 'rss':
                rss_url = "https://www.bbc.co.uk/news/10628494"
                rss_headlines = get_rss_feed(rss_url)
                speak(rss_headlines)
            elif token.text.lower() == 'google':
                search_google(query)
                speak("Here are the search results from Google.")
            elif token.text.lower() == 'wikipedia':
                wikipedia_result = search_wikipedia(query)
                speak(wikipedia_result)
