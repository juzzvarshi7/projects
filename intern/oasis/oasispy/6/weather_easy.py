import requests
weather_api_key = "916e3edbc3679db39f5cdb6ed42b5d66"

def get_weather(city):
    url=f"http://api.openweathermap.org/data/2.5/weather?q={city}&appid={weather_api_key}"
    response = requests.get(url)
    if response.status_code==200:
        data = response.json()
        weather_description = data['weather'][0]['description']
        temperature = data['main']['temp']
        temperature_celsius = round(temperature-273.15, 2)
        humidity = data['main']['humidity']
        return f"Weather in {city}: {weather_description}\nTemperature: {temperature_celsius}°C\nHumidity: {humidity}%"
    else:
        return "Sorry, I couldn't fetch the weather information at the moment."
    
def main():
    city = input("Enter the name of the city: ")
    weather_info = get_weather(city)
    print(weather_info)

if __name__=="__main__":
    main()