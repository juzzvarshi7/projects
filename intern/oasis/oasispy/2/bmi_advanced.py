import tkinter as tk
from tkinter import messagebox

# Unit conversion dictionary
unit_conversion = {
    "m": 1,  # Meters to meters (no conversion)
    "ft": 0.3048,  # Feet to meters conversion factor
    "kg": 1,  # Kilograms to kilograms (no conversion)
    "lb": 0.453592,  # Pounds to kilograms conversion factor
}


def calculate_bmi():
    try:
        # Get user input and selected units
        height_str = height_entry.get()
        weight_str = weight_entry.get()
        selected_height_unit = height_unit_var.get()
        selected_weight_unit = weight_unit_var.get()

        # Validate input based on selected unit
        if not all(char.isdigit() or char == "." for char in height_str) or not all(char.isdigit() or char == "." for char in weight_str):
            messagebox.showerror("Error", "Please enter numeric values for height and weight.")
            return

        # Convert values to meters and kilograms based on units
        height = float(height_str) * unit_conversion[selected_height_unit]
        weight = float(weight_str) * unit_conversion[selected_weight_unit]

        bmi = weight / (height ** 2)

        # Update BMI result with two decimal places
        bmi_result_label.config(text=f"BMI: {bmi:.2f}")

        # Set category label and add interpretation
        if bmi < 18.5:
            category_label.config(text="Category: Underweight (Below normal weight)")
        elif bmi < 25:
            category_label.config(text="Category: Normal weight (Healthy weight)")
        elif bmi < 30:
            category_label.config(text="Category: Overweight (Above normal weight)")
        else:
            category_label.config(text="Category: Obesity (Excessive weight for height)")

    except ValueError:
        messagebox.showerror("Error", "Unexpected error occurred.")


# GUI setup
root = tk.Tk()
root.title("BMI Calculator")

background_color = "#f0f0f0"
root.configure(bg=background_color)

# Styles
entry_style = {"bg": "white", "fg": "black", "font": ("Arial", 12)}
label_style = {"bg": background_color, "fg": "black", "font": ("Arial", 12)}

# Height label and entry
height_label = tk.Label(root, text="Height:")
height_label.grid(row=0, column=0)

height_entry = tk.Entry(root)
height_entry.grid(row=0, column=1)

# Height unit selection
height_unit_var = tk.StringVar(root)
height_unit_var.set("m")  # Default unit

height_unit_menu = tk.OptionMenu(root, height_unit_var, "m", "ft")
height_unit_menu.grid(row=0, column=2)

# Weight label and entry
weight_label = tk.Label(root, text="Weight:")
weight_label.grid(row=1, column=0)

weight_entry = tk.Entry(root)
weight_entry.grid(row=1, column=1)

# Weight unit selection
weight_unit_var = tk.StringVar(root)
weight_unit_var.set("kg")  # Default unit

weight_unit_menu = tk.OptionMenu(root, weight_unit_var, "kg", "lb")
weight_unit_menu.grid(row=1, column=2)

calculate_button = tk.Button(root, text="Calculate BMI", command=calculate_bmi)
calculate_button.grid(row=2, columnspan=2)

bmi_result_label = tk.Label(root, text="")
bmi_result_label.grid(row=3, columnspan=2)

category_label = tk.Label(root, text="")
category_label.grid(row=4, columnspan=2)

# No unit label needed anymore (removed)

root.mainloop()
