class Outfit:
    def __init__(self, name, category, price, color):
        self.name = name
        self.category = category
        self.price = price
        self.color = color

outfits = [
    Outfit("Outfit 1", "Tops", 20, "Red"),
    Outfit("Outfit 2", "Bottoms", 30, "Blue"),
    Outfit("Outfit 3", "Tops", 25, "Green"),
    Outfit("Outfit 4", "Accessories", 15, "Yellow"),
    Outfit("Outfit 5", "Bottoms", 40, "Black"),
]

def search_outfits(keyword):
    results = []
    for outfit in outfits:
        if keyword.lower() in outfit.name.lower():
            results.append(outfit)
    return results

def filter_outfits_by_price(max_price):
    results = []
    for outfit in outfits:
        if outfit.price <= max_price:
            results.append(outfit)
    return results

def filter_outfits_by_category(category):
    results = []
    for outfit in outfits:
        if outfit.category.lower() == category.lower():
            results.append(outfit)
    return results

def display_outfits(outfits):
    if not outfits:
        print("No outfits found.")
    else:
        for outfit in outfits:
            print(f"Name: {outfit.name}")
            print(f"Category: {outfit.category}")
            print(f"Price: ${outfit.price}")
            print(f"Color: {outfit.color}")
            print()

def main():
    while True:
        print("Welcome to the Outfit Store!")
        print("1. Search for an outfit")
        print("2. Filter outfits by price")
        print("3. Filter outfits by category")
        print("4. Exit")
        choice = input("Enter your choice (1-4): ")

        if choice == '1':
            keyword = input("Enter a keyword to search for outfits: ")
            results = search_outfits(keyword)
            display_outfits(results)
        elif choice == '2':
            max_price = float(input("Enter the maximum price: "))
            results = filter_outfits_by_price(max_price)
            display_outfits(results)
        elif choice == '3':
            category = input("Enter the category to filter by: ")
            results = filter_outfits_by_category(category)
            display_outfits(results)
        elif choice == '4':
            print("Thank you for using the Outfit Store. Goodbye!")
            break
        else:
            print("Invalid choice. Please try again.")

if __name__ == '__main__':
    main()
