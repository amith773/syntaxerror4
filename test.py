import sys
import os
import pygame

# Initialize Pygame
pygame.init()
pygame.font.init()

# Screen Configuration (Matches standard 16:9 image aspect ratio)
WIDTH, HEIGHT = 1280, 720
screen = pygame.display.set_mode((WIDTH, HEIGHT))
pygame.display.set_caption("IIT Roorkee Time Paradox - Campus Overworld")
clock = pygame.time.Clock()

# Color Palette
COLOR_PLAYER = (255, 193, 7)     # Player Character Gold
COLOR_PROMPT_BG = (20, 20, 20)  # Dark HUD Banner
COLOR_PROMPT_TXT = (76, 175, 80) # Interactive Green Text
COLOR_LOCKED_TXT = (211, 47, 47) # Warning Red Text
COLOR_TEXT = (255, 255, 255)

# Fonts
FONT_TITLE = pygame.font.SysFont("Arial", 24, bold=True)
FONT_HUD = pygame.font.SysFont("Arial", 18, bold=True)

# -------------------------------------------------------------
# 1. MAP BACKGROUND LOADER
# -------------------------------------------------------------
BACKGROUND_IMAGE_PATH = "campus_map.png"  # Save your image with this name in the same folder

map_background = None
if os.path.exists(BACKGROUND_IMAGE_PATH):
    loaded_img = pygame.image.load(BACKGROUND_IMAGE_PATH)
    map_background = pygame.transform.scale(loaded_img, (WIDTH, HEIGHT))

# -------------------------------------------------------------
# 2. GAME STATE & BUILDING COORDINATES
# -------------------------------------------------------------
class GameState:
    def __init__(self):
        # Sequential Route: 1=Main Gate, 2=Library, 3=LBS Ground, 4=SAC, 5=Sarojini Bhawan, 6=Main Building
        self.unlocked_building = 1 
        self.player_map_pos = [628, 620]  # Spawns right outside Main Gate

state = GameState()

# Precise Building Hitboxes matched directly to your image layout:
BUILDINGS = [
    {
        "id": 1, 
        "name": "Main Gate", 
        "rect": pygame.Rect(540, 630, 180, 70),
        "spawn": (628, 620)
    },
    {
        "id": 2, 
        "name": "Library", 
        "rect": pygame.Rect(260, 480, 180, 110),
        "spawn": (350, 520)
    },
    {
        "id": 3, 
        "name": "LBS Ground", 
        "rect": pygame.Rect(830, 230, 310, 180),
        "spawn": (980, 320)
    },
    {
        "id": 4, 
        "name": "SAC", 
        "rect": pygame.Rect(840, 500, 160, 120),
        "spawn": (920, 550)
    },
    {
        "id": 5, 
        "name": "Sarojini Bhawan", 
        "rect": pygame.Rect(1080, 510, 150, 140),
        "spawn": (1155, 580)
    },
    {
        "id": 6, 
        "name": "Main Building Thomson", 
        "rect": pygame.Rect(470, 250, 310, 160),
        "spawn": (625, 330)
    }
]

# -------------------------------------------------------------
# 3. TOP-DOWN PLAYER
# -------------------------------------------------------------
class MapPlayer:
    def __init__(self, pos):
        self.rect = pygame.Rect(pos[0], pos[1], 20, 20)
        self.speed = 5

    def handle_movement(self):
        keys = pygame.key.get_pressed()
        dx, dy = 0, 0
        if keys[pygame.K_a] or keys[pygame.K_LEFT]:  dx -= 1
        if keys[pygame.K_d] or keys[pygame.K_RIGHT]: dx += 1
        if keys[pygame.K_w] or keys[pygame.K_UP]:    dy -= 1
        if keys[pygame.K_s] or keys[pygame.K_DOWN]:  dy += 1

        if dx != 0 and dy != 0:
            dx *= 0.7071
            dy *= 0.7071

        self.rect.x += int(dx * self.speed)
        self.rect.y += int(dy * self.speed)
        self.rect.clamp_ip(screen.get_rect())

# -------------------------------------------------------------
# 4. CUSTOM LEVEL HANDLERS (PLUG YOUR PUZZLES HERE)
# -------------------------------------------------------------
def run_level_1_main_gate():
    return placeholder_level_runner("Level 1: Main Gate")

def run_level_2_library():
    return placeholder_level_runner("Level 2: Library")

def run_level_3_lbs_ground():
    return placeholder_level_runner("Level 3: LBS Ground")

def run_level_4_sac():
    return placeholder_level_runner("Level 4: SAC")

def run_level_5_sarojini():
    return placeholder_level_runner("Level 5: Sarojini Bhawan")

def run_level_6_main_building():
    return placeholder_level_runner("Level 6: Main Building Thomson")

LEVEL_HANDLERS = {
    1: run_level_1_main_gate,
    2: run_level_2_library,
    3: run_level_3_lbs_ground,
    4: run_level_4_sac,
    5: run_level_5_sarojini,
    6: run_level_6_main_building
}

def placeholder_level_runner(level_title):
    """
    Replace the code inside this loop (or inside the run_level_X functions) 
    with your own Pygame level/puzzle script!
    """
    in_level = True
    cleared = False

    while in_level:
        clock.tick(60)
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()
                sys.exit()
            if event.type == pygame.KEYDOWN:
                if event.key == pygame.K_RETURN:  # ENTER clears the puzzle level
                    cleared = True
                    in_level = False
                if event.key == pygame.K_ESCAPE:  # ESC exits to map without clearing
                    in_level = False

        screen.fill((25, 25, 35))
        title = FONT_TITLE.render(f"Puzzles for: {level_title}", True, (255, 255, 255))
        sub = FONT_HUD.render("Press [ENTER] to Clear Level & Unlock Next | [ESC] Exit to Map", True, (180, 180, 180))
        screen.blit(title, (60, 250))
        screen.blit(sub, (60, 300))
        pygame.display.flip()

    return cleared

# -------------------------------------------------------------
# 5. MAIN OVERWORLD LOOP
# -------------------------------------------------------------
def main():
    map_player = MapPlayer(state.player_map_pos)

    running = True
    while running:
        clock.tick(60)
        map_player.handle_movement()

        # Check standing collision with any building
        active_building = None
        for b in BUILDINGS:
            if map_player.rect.colliderect(b["rect"]):
                active_building = b
                break

        # Event Handling
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False

            elif event.type == pygame.KEYDOWN:
                # Key press required to enter building
                if event.key in (pygame.K_e, pygame.K_SPACE):
                    if active_building:
                        # Check if building is unlocked
                        if active_building["id"] <= state.unlocked_building:
                            handler = LEVEL_HANDLERS.get(active_building["id"])
                            if handler:
                                level_cleared = handler()
                                
                                # If beat level, unlock next building
                                if level_cleared and state.unlocked_building == active_building["id"]:
                                    state.unlocked_building += 1
                                
                                # Move player slightly away from trigger box so it doesn't loop
                                map_player.rect.y += 25

        # Render Map Background
        if map_background:
            screen.blit(map_background, (0, 0))
        else:
            screen.fill((100, 160, 90)) # Fallback Grass Color

        # Draw Player
        pygame.draw.rect(screen, COLOR_PLAYER, map_player.rect, border_radius=3)
        pygame.draw.rect(screen, (0, 0, 0), map_player.rect, width=2, border_radius=3)

        # Draw Interaction Prompt Banner when over a building
        if active_building:
            prompt_rect = pygame.Rect(WIDTH//2 - 280, HEIGHT - 70, 560, 50)
            pygame.draw.rect(screen, COLOR_PROMPT_BG, prompt_rect, border_radius=8)
            pygame.draw.rect(screen, COLOR_TEXT, prompt_rect, width=2, border_radius=8)

            if active_building["id"] <= state.unlocked_building:
                msg = f"Press [E] or [SPACE] to enter {active_building['name']}"
                txt = FONT_HUD.render(msg, True, COLOR_PROMPT_TXT)
            else:
                msg = f"{active_building['name']} is LOCKED! Complete previous building first."
                txt = FONT_HUD.render(msg, True, COLOR_LOCKED_TXT)

            txt_rect = txt.get_rect(center=prompt_rect.center)
            screen.blit(txt, txt_rect)

        pygame.display.flip()

    pygame.quit()
    sys.exit()

if __name__ == "__main__":
    main()