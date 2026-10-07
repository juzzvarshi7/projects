import pygame
import time

# Constants for colors
BLACK = (0, 0, 0)
WHITE = (255, 255, 255)
GRAY = (200, 200, 200)
DARK_GRAY = (150, 150, 150)  # New color for input box border
BUTTON_COLOR = (100, 100, 100)
BUTTON_TEXT_COLOR = (255, 255, 255)
SCROLLBAR_COLOR = (150, 150, 150)
SCROLLBAR_BUTTON_COLOR = (100, 100, 100)

# Constants for grid size
GRID_SIZE = 50
GRID_WIDTH = 10
GRID_HEIGHT = 10

# Initialize Pygame
pygame.init()

# Set up the display
WINDOW_WIDTH = GRID_SIZE * GRID_WIDTH + 400  # Increased width for buttons and function window
WINDOW_SIZE = (WINDOW_WIDTH, GRID_SIZE * GRID_HEIGHT)
screen = pygame.display.set_mode(WINDOW_SIZE)
pygame.display.set_caption("Wolg's World")

robot_img_orig = pygame.Surface((GRID_SIZE, GRID_SIZE))  # Placeholder image
robot_img_orig.fill((255, 0, 0))  # Red square for placeholder
robot_img = pygame.transform.scale(robot_img_orig, (GRID_SIZE, GRID_SIZE))  # Resize to grid size

# Font for text input
font = pygame.font.SysFont(None, 30)

# Input box parameters
input_box = pygame.Rect(GRID_SIZE * GRID_WIDTH + 20, 100, 160, 40)
input_text = ''
input_active = False  # Flag to track if input box is active

# Define the functions (replace these with your actual functions)
class Robot:
    def __init__(self, x, y):
        self.x = x
        self.y = y
        self.direction = 'up'  # Initial direction

    def move(self):
        if self.direction == 'up':
            self.y -= 1
        elif self.direction == 'down':
            self.y += 1
        elif self.direction == 'left':
            self.x -= 1
        elif self.direction == 'right':
            self.x += 1

    def turn_left(self):
        directions = ['up', 'left', 'down', 'right']
        current_index = directions.index(self.direction)
        new_index = (current_index + 1) % 4
        self.direction = directions[new_index]

class World:
    def __init__(self, width, height):
        self.width = width
        self.height = height

class UsedRobot:
    def __init__(self, world, x, y):
        self.world = world
        self.robot = Robot(x, y)
# Replace with your world dimensions
world = World(GRID_WIDTH, GRID_HEIGHT)  # Create an instance of your world

# Initial robot position (adjust as needed)
robot_x = 0
robot_y = 0

# Create an instance of UsedRobot
used_robot = UsedRobot(world, robot_x, robot_y)

# Define your actual functions here (replace these)
def move():
    used_robot.robot.move()

def turn_left():
    used_robot.robot.turn_left()

def take():
    print("Taking something...")  # Replace with actual logic

def put():
    print("Putting something...")  # Replace with actual logic

def build_wall():
    print("Building a wall...")  # Replace with actual logic

def pause():
    time.sleep(1)  # Pause execution for 1 second

def done():
    global running
    running = False  # Stop the main loop

def think(delay):
    time.sleep(delay / 1000)  # Pause execution for the specified delay in milliseconds

# Playing sound (replace with actual logic)
def sound(enable):
    print("Playing sound..." if enable else "Sound disabled")

# Define command functions dictionary
command_functions = {
    "move": move,
    "turn_left": turn_left,
    "take": take,
    "put": put,
    "build_wall": build_wall,
    "pause": pause,
    "done": done,
    "think(100)": think,
    "sound(True)": sound,
}

# Function to display functions in a separate window (optional)
def display_functions():
    # Create a separate window for functions
    functions_window = pygame.display.set_mode((200, 350))  # Increased height for the back button
    pygame.display.set_caption("Functions")

    # List of functions (replace with your actual commands)
    functions = ["move", "turn_left", "take", "put", "build_wall", "pause", "done", "think(100)", "sound(True)"]

    # Font for displaying functions
    function_font = pygame.font.SysFont(None, 20)

    running_functions = True
    while running_functions:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running_functions = False
            elif event.type == pygame.MOUSEBUTTONDOWN:
                if back_button_rect.collidepoint(event.pos):  # Check if the back button is clicked
                    return True  # Return True if the back button is clicked

        # Clear the functions window
        functions_window.fill(WHITE)

        # Display function list
        for i, func in enumerate(functions):
            func_text = function_font.render(func, True, BLACK)
            functions_window.blit(func_text, (10, 10 + i * 25))

        # Draw the back button
        back_button_rect = pygame.Rect(50, 300, 100, 40)  # Position and size of the back button
        pygame.draw.rect(functions_window, BUTTON_COLOR, back_button_rect)  # Draw button with color
        back_text = font.render("Back", True, BUTTON_TEXT_COLOR)
        functions_window.blit(back_text, (back_button_rect.centerx - back_text.get_width() // 2, back_button_rect.centery - back_text.get_height() // 2))

        # Update the functions window
        pygame.display.flip()

    # Close the functions window after exiting the loop
    pygame.display.quit()
# Define constants for functions button position and size
functions_button_width = 150
functions_button_height = 50
functions_button_x = GRID_SIZE * GRID_WIDTH + 20
functions_button_y = 200

# Create a rectangle for the functions button
functions_button_rect = pygame.Rect(functions_button_x, functions_button_y, functions_button_width, functions_button_height)

# Main loop
running = True
while running:
    # Handle events
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False
        elif event.type == pygame.KEYDOWN:
            if input_active:
                if event.key == pygame.K_RETURN:
                    # Process the entered command
                    if input_text in command_functions:
                        command_functions[input_text]()  # Call the corresponding function
                    else:
                        print("Invalid command:", input_text)
                    input_text = ''  # Clear the input box after processing
                elif event.key == pygame.K_BACKSPACE:
                    input_text = input_text[:-1]  # Remove the last character
                else:
                    # Add the pressed key to input_text
                    input_text += event.unicode  # Append the unicode character to input_text
            elif event.key == pygame.K_ESCAPE:
                running = False
        elif event.type == pygame.MOUSEBUTTONDOWN:
            if input_box.collidepoint(event.pos):
                input_active = True
            else:
                input_active = False
            if functions_button_rect.collidepoint(event.pos):
                display_functions()

    # Draw the grid
    screen.fill(WHITE)
    for row in range(GRID_HEIGHT):
        for col in range(GRID_WIDTH):
            color = WHITE if (row + col) % 2 == 0 else GRAY
            pygame.draw.rect(screen, color, [col * GRID_SIZE, row * GRID_SIZE, GRID_SIZE, GRID_SIZE])

    # Draw the robot
    screen.blit(robot_img, (used_robot.robot.x * GRID_SIZE, used_robot.robot.y * GRID_SIZE))

    # Draw the input box
    pygame.draw.rect(screen, DARK_GRAY, input_box, 2)  # Draw border with thickness 2
    text_surface = font.render(input_text, True, BLACK)
    screen.blit(text_surface, (input_box.x + 5, input_box.y + 5))  # Add a padding of 5 pixels

    # Draw the functions button
    pygame.draw.rect(screen, BUTTON_COLOR, functions_button_rect)  # Draw the button
    button_text = font.render("Functions", True, BUTTON_TEXT_COLOR)  # Render the button text
    screen.blit(button_text, (functions_button_rect.x + (functions_button_rect.width - button_text.get_width()) // 2, functions_button_rect.y + (functions_button_rect.height - button_text.get_height()) // 2))

    # Print button positions and dimensions for debugging
    print("Functions Button Rect:", functions_button_rect)

    # Update the display
    pygame.display.flip()

# Quit Pygame
pygame.quit()
