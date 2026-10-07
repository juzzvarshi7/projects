function convertTemperature() {
    var temperatureInput = parseFloat(document.getElementById("temperature").value);
    var fromUnit = document.getElementById("fromUnit").value;
    var toUnit = document.getElementById("toUnit").value;
    var resultElement = document.getElementById("result");
    var convertedTemperature;

    if (isNaN(temperatureInput)) {
        resultElement.innerText = "Please enter a valid number for temperature.";
        return;
    }

    if (fromUnit === toUnit) {
        resultElement.innerText = "Please select different units to convert from and to.";
        return;
    }

    switch (fromUnit) {
        case "celsius":
            convertedTemperature = temperatureInput + 273.15; // Celsius to Kelvin
            break;
        case "fahrenheit":
            convertedTemperature = (temperatureInput - 32) * 5 / 9 + 273.15; // Fahrenheit to Kelvin
            break;
        case "kelvin":
            convertedTemperature = temperatureInput;
            break;
    }

    switch (toUnit) {
        case "celsius":
            convertedTemperature -= 273.15; // Kelvin to Celsius
            break;
        case "fahrenheit":
            convertedTemperature = (convertedTemperature - 273.15) * 9 / 5 + 32; // Kelvin to Fahrenheit
            break;
        case "kelvin":
            // Temperature is already in Kelvin
            break;
    }

    resultElement.innerText = "Converted Temperature: " + convertedTemperature.toFixed(2) + " " + toUnit.toUpperCase();
}
