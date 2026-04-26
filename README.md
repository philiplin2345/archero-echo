# Archero Echo 🏹

A high-performance iOS game built with **Swift** and **SpriteKit**, inspired by the popular roguelike action game *Archero*. This project demonstrates native iOS game development patterns, physics integration, and robust unit testing.

![Platform: iOS](https://img.shields.io/badge/platform-iOS-blue.svg)
![Language: Swift](https://img.shields.io/badge/language-Swift-orange.svg)
![Framework: SpriteKit](https://img.shields.io/badge/framework-SpriteKit-brightgreen.svg)
![Testing: Swift Testing](https://img.shields.io/badge/testing-Swift_Testing-blueviolet.svg)

## 🎮 Gameplay Features

- **One-Touch Movement**: A dynamic virtual joystick that appears anywhere you touch.
- **Archero Combat**: Move to dodge, stop to shoot. The player auto-aims at the nearest enemy when standing still.
- **Wave System**: Increasingly difficult waves of enemies with automated spawning.
- **Physics-Based Combat**: Pixel-perfect collision detection for projectiles and contact damage.
- **Game Loop**: Smooth 60 FPS performance optimized for mobile hardware.

## 🛠 Tech Stack

- **Language**: Swift 6.0
- **Engine**: SpriteKit (Native Apple 2D Engine)
- **Architecture**: Object-Oriented Node-based architecture
- **Testing**: Swift Testing (Apple's modern testing framework)

## 📂 Project Structure

- `GameScene.swift`: The main orchestrator of the game world.
- `PlayerNode.swift`: Handles player movement logic and auto-shooting.
- `EnemyNode.swift`: Melee AI logic and health management.
- `JoystickNode.swift`: Custom-built virtual input controller.
- `WaveManager.swift`: Logic for enemy spawning and wave progression.
- `archero-echoTests/`: Comprehensive test suite covering core game logic.

## 🚀 Getting Started

### Prerequisites
- macOS with **Xcode 16.0** or later installed.
- Basic knowledge of Swift and SpriteKit.

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/philiplin2345/archero-echo.git
   ```
2. Open `archero-echo.xcodeproj` in Xcode.
3. Select an iOS Simulator (e.g., iPhone 15 Pro).
4. Press **⌘R** to Run.

### Running Tests
This project maintains a high standard of code reliability with over 30 unit tests.
- Press **⌘U** to execute the test suite.
- View code coverage in the **Report Navigator**.

## 📖 Learning Resources
If you are new to the codebase, check out the [CODE_WALKTHROUGH.md](CODE_WALKTHROUGH.md) for a step-by-step explanation of how the app launches and executes.

---

*Created as a demonstration of agentic AI coding and modern iOS development practices.*
