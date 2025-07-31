# Go One Game Demo

## Description

**Go One Game** is a one-handed gaming controller project. 
This is a game which can be used for demonstration purposes, and to help users familiarize themselves with the controller on an easy game.
The player has a limited amount of time to complete a level while scoring as many points as possible by shooting targets.

### Features

- **Camera-relative movement** with jumping mechanics
- **Shooting system** with targets and scorekeeping
- **Obstacles** that push the player away
- **Falling & respawn** mechanics
- **Timed levels** with end platform to reach before timeout
- **Level selection menu** and **transition screens** between levels
- **Progress saving** to keep track of unlocked levels and best scores
- **Controls settings** to remap game controls

## Installation

### Prerequisites
- **Godot Engine** (download: https://godotengine.org/download/windows/)

### Instructions
1. Clone the repository:
```bash
 git clone https://github.com/autonabee/go_one_game_jeu_demo.git
```

2. Open the project in Godot: 
- Launch Godot and click on "Import"
- Select the `project.godot`file

3. Run the `main.tscn` file or press **F5** to start the game

## File Overview

- `assets/` : Contains models, materials, images and fonts used in the game
	- `assets/map_assets_ready/` : Prebuilt scenes of obstacles and targets, ready to be placed in a map
- `autoload/` : Contains scripts that are global variables
- `maps/` : Contains the game levels
- `player/` : Scenes and scripts for the player, gun and bullet 
- `ui/` : Level selection menu, controls settings and transition screens
- `main.tscn` and `main.gd` : Main scene and script to start the game

## Possible Improvements

- **Gun reticle** : Currently a sprite attached to the gun. It's not well-calibrated and can sometimes appear behind a target if the target is closer to the player.
- **Respawning** : The player respawns at the last position on the floor before the fall. If the player is in movement, it sometimes causes an endless falling and respawning loop.
- **Movement** : The game is very sensitive along the x-axis which can cause some sharp turns.
- **User interface** : The game isn't paused between the end of a level and the beginning of another.
- **Controls settings** : Doesn't detect if one event is attributed to different actions
- **Add a pause button** and access to the menus in a level

## Credits

Credits for all the assets used can be found in `CREDITS.md`.
