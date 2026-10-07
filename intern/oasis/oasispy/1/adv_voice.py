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
weather_api_key = "YOUR_OPENWEATHERMAP_API_KEY"

# News API key
news_api_key = "YOUR_NEWS_API_KEY"

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
        return f"Sorry, I couldn't fetch the weather information at the moment. Error code: {response.status_code}"

# Function to get latest news headlines
def get_news(query):
    url = f"https://newsapi.org/v2/everything?q={query}&apiKey={news_api_key}"
    response = requests.get(url)
    if response.status_code == 200:
        data = response.json()
        headlines = [article['title'] for article in data['articles']]
        return "Here are the latest news headlines related to coronavirus:\n" + "\n".join(headlines)
    else:
        return f"Sorry, I couldn't fetch the news headlines at the moment. Error code: {response.status_code}"

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
        # Debugging: print recognized entities and tokens
        print("Recognized tokens:", [token.text for token in doc])
        print("Recognized entities:", [(ent.text, ent.label_) for ent in doc.ents])
        
        if 'weather' in query.lower():
            city = ""
            for ent in doc.ents:
                if ent.label_ == "GPE":
                    city = ent.text
                    break
            if city:
                weather_info = get_weather(city)
                print(weather_info)  # Added print statement for debugging
                speak(weather_info)
            else:
                speak("Please specify a city.")
        elif 'news' in query.lower():
            news_headlines = get_news("coronavirus")
            print(news_headlines)  # Added print statement for debugging
            speak(news_headlines)
        elif 'rss' in query.lower():
            rss_url = "https://www.bbc.co.uk/news/10628494"
            rss_headlines = get_rss_feed(rss_url)
            print(rss_headlines)  # Added print statement for debugging
            speak(rss_headlines)
        elif 'google' in query.lower():
            search_google(query)
            speak("Here are the search results from Google.")
        elif 'wikipedia' in query.lower():
            wikipedia_result = search_wikipedia(query)
            print(wikipedia_result)  # Added print statement for debugging
            speak(wikipedia_result)
