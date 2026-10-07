import pygame
import random
import sys

# Initialize Pygame
pygame.init()

# Constants
WIDTH, HEIGHT = 800, 600
CAR_WIDTH, CAR_HEIGHT = 60, 100
FPS = 60
CAR_SPEED = 7
ENEMY_CAR_SPEED = 5
ENEMY_CAR_HEIGHT = 80
ENEMY_CAR_WIDTH = 60

# Colors
WHITE = (255, 255, 255)
RED = (255, 0, 0)
GREEN = (0, 255, 0)
BLUE = (0, 0, 255)

# Create the game window
window = pygame.display.set_mode((WIDTH, HEIGHT))
pygame.display.set_caption("Car Game")

# Load images
car_img = pygame.image.load("car.png")
car_img = pygame.transform.scale(car_img, (CAR_WIDTH, CAR_HEIGHT))

background_img = pygame.image.load("carbg.png")
background_img = pygame.transform.scale(background_img, (WIDTH, HEIGHT))

# Function to draw the car on the window
def draw_car(x, y):
    window.blit(car_img, (x, y))

# Function to draw enemy car
def draw_enemy_car(x, y):
    pygame.draw.rect(window, RED, (x, y, ENEMY_CAR_WIDTH, ENEMY_CAR_HEIGHT))

# Function to handle collisions
def check_collision(x1, y1, w1, h1, x2, y2, w2, h2):
    if x1 < x2 + w2 and x1 + w1 > x2 and y1 < y2 + h2 and y1 + h1 > y2:
        return True
    return False

# Home page
def home():
    font = pygame.font.Font(None, 72)
    start_text = font.render("Start", True, GREEN)
    instruction_text = font.render("Instructions", True, GREEN)

    while True:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()
                sys.exit()

            if event.type == pygame.MOUSEBUTTONDOWN:
                mouse_x, mouse_y = pygame.mouse.get_pos()
                if WIDTH // 2 - 100 <= mouse_x <= WIDTH // 2 + 100 and HEIGHT // 2 - 50 <= mouse_y <= HEIGHT // 2:
                    return

        window.fill(WHITE)
        window.blit(background_img, (0, 0))
        window.blit(start_text, (WIDTH // 2 - 100, HEIGHT // 2 - 50))
        window.blit(instruction_text, (WIDTH // 2 - 150, HEIGHT // 2 + 50))
        pygame.display.update()

# Game loop
def main():
    home()
    clock = pygame.time.Clock()

    car_x = WIDTH // 2 - CAR_WIDTH // 2
    car_y = HEIGHT - CAR_HEIGHT - 20
    car_x_change = 0

    enemy_cars = []
    enemy_spawn_counter = 0

    score = 0

    while True:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()
                sys.exit()

            if event.type == pygame.KEYDOWN:
                if event.key == pygame.K_LEFT:
                    car_x_change = -CAR_SPEED
                elif event.key == pygame.K_RIGHT:
                    car_x_change = CAR_SPEED

            if event.type == pygame.KEYUP:
                if event.key == pygame.K_LEFT or event.key == pygame.K_RIGHT:
                    car_x_change = 0

        # Update car position
        car_x += car_x_change
        if car_x < 0:
            car_x = 0
        elif car_x > WIDTH - CAR_WIDTH:
            car_x = WIDTH - CAR_WIDTH

        # Spawn enemy car
        if enemy_spawn_counter == 0:
            enemy_cars.append([random.randint(0, WIDTH - ENEMY_CAR_WIDTH), -ENEMY_CAR_HEIGHT])
            enemy_spawn_counter = 50
        else:
            enemy_spawn_counter -= 1

        # Move enemy cars
        for enemy_car in enemy_cars:
            enemy_car[1] += ENEMY_CAR_SPEED
            if enemy_car[1] > HEIGHT:
                enemy_cars.remove(enemy_car)
                score += 1

        # Check for collisions
        for enemy_car in enemy_cars:
            if check_collision(car_x, car_y, CAR_WIDTH, CAR_HEIGHT, enemy_car[0], enemy_car[1], ENEMY_CAR_WIDTH, ENEMY_CAR_HEIGHT):
                pygame.quit()
                sys.exit()

        # Draw everything on the screen
        window.fill(WHITE)
        window.blit(background_img, (0, 0))
        draw_car(car_x, car_y)
        for enemy_car in enemy_cars:
            draw_enemy_car(enemy_car[0], enemy_car[1])

        # Show score
        font = pygame.font.Font(None, 36)
        score_text = font.render("Score: " + str(score), True, GREEN)
        window.blit(score_text, (10, 10))

        pygame.display.update()
        clock.tick(FPS)

if __name__ == "__main__":
    main()
