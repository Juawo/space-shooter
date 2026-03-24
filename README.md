# 🚀 OuterSpace - Mobile Space Shooter
![Godot](https://img.shields.io/badge/Godot-Engine-478CBF?style=for-the-badge&logo=godot-engine&logoColor=white)
![Excalidraw](https://img.shields.io/badge/Excalidraw-Wireframes-6965DB?style=for-the-badge)

A mobile space shooter focused on gameplay progression and competitive ranking, featuring player registration and a global leaderboard.

Designed to go beyond generic arcade shooters by combining fast-paced gameplay with backend-driven competition systems.

---

## 📚 Table of Contents

- [Features](#features)
- [Gameplay Loop](#gameplay-loop)
- [Technical Decisions](#technical-decisions)
- [Tech Stack](#tech-stack)
- [Screenshots & Design](#screenshots--design)
- [How to Run](#how-to-run)
- [Project Status](#project-status)
- [Differentials](#differentials)
- [Future Improvements](#future-improvements)
- [Related Projects](#related-projects)

---

## Features

- Player registration system
- Global leaderboard
- High score tracking
- Endless gameplay (survive as long as possible)
- Mobile-focused design

---

## Gameplay Loop

```text
Start game
↓
Survive enemy waves
↓
Score increases over time
↓
Player dies
↓
Submit score
↓
Check leaderboard
↓
Play again to improve ranking
```

This loop creates a competitive and replayable experience focused on performance and ranking.

## Technical Decisions

**Backend Integration for Leaderboard**
Player scores are stored and retrieved from a backend API, enabling global competition.

**Simple Core Loop First**
The game prioritizes a functional gameplay loop before adding visual polish and extra features.

**Mobile-Oriented Design**
The game is designed to run efficiently on mobile devices, focusing on performance and responsiveness.

## Tech Stack

![Godot](https://img.shields.io/badge/Godot-Engine-478CBF?style=for-the-badge&logo=godot-engine&logoColor=white)
![Excalidraw](https://img.shields.io/badge/Excalidraw-Wireframes-6965DB?style=for-the-badge)


## Screenshots & Design

Add gameplay screenshots and GIFs here

Add UI sketches or wireframes here

## How to Run
```
Clone the repository:

git clone <REPO_URL>

Open the project in Godot Engine

Configure backend API URL (if required)

Run the project

(Optional) Export as APK to test on mobile devices
```
## Project Status

Prototype — core gameplay and leaderboard system are functional, currently expanding with visuals and polish.

## Differentials

- Integration with backend systems (player accounts + leaderboard)

- Focus on competitive gameplay rather than pure arcade experience

- Designed as a fullstack game (client + server)

- Strong replayability loop driven by ranking systems

## Future Improvements

- Visual assets (sprites, effects, UI polish)

- Sound effects and background music

- Game juice (screen shake, particles, feedback)

- Enemy variety and behavior patterns

- Difficulty scaling system

- Power-ups and weapon systems

- UI/UX improvements

- Performance optimizations

## Related Projects

🧠 Backend API: https://github.com/Juawo/space-shooter-api