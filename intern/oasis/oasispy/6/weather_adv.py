import requests
import tkinter as tk
from tkinter import ttk

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

root = tk.Tk()
root.title("Weather App")

city_label = ttk.Label(root, text = "Enter city: ")
city_label.grid(row=0, column=0, padx=10, pady=10, sticky="w")

city_entry = ttk.Entry(root)
city_entry.grid(row=0, column=1, padx=10, pady=10, sticky="we")

def get_weather_for_city():
    city = city_entry.get()
    weather_info = get_weather(city)
    result_label.config(text=weather_info)

get_weather_button = ttk.Button(root, text="Get Weather", command=get_weather_for_city)
get_weather_button.grid(row=1, column=0, columnspan=2, padx=10, pady=10, sticky="we")

result_label = tk.Label(root, text="")
result_label.grid(row=2, column=0, columnspan=2, padx=10, pady=10, sticky="we")

root.mainloop()