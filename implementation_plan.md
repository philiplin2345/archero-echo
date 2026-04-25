# Archero Clone — iOS MVP

Build a minimum viable Archero-style top-down shooter for iOS using **Swift + SpriteKit** (hosted in SwiftUI via `SpriteView`).

## MVP Scope

| Feature | Description |
|---|---|
| **Player** | Hero sprite that moves via virtual joystick; auto-shoots the nearest enemy when standing still |
| **Enemies** | Basic melee enemies that chase the player; spawned in waves |
| **Projectiles** | Bullets fly toward nearest enemy, deal damage on contact |
| **Health** | Player and enemies have HP; damage dealt on collision |
| **HUD** | Health bar + score counter overlay |
| **Game loop** | Wave-based spawning → clear all enemies → next wave; game over on death with restart |

> [!NOTE]
> This is an MVP — no power-up selection, no room transitions, no boss fights yet. These can be layered on after the core loop is solid.

---

## Proposed Changes

### Project Bootstrap

#### [NEW] Xcode project via `swift package init` + manual SpriteKit setup

We'll create the project files directly (no `xcodegen` dependency). The files will be placed in the workspace directory and can be opened in Xcode.

**Directory layout:**

```
archero-clone/
├── ArcheroClone/
│   ├── App/
│   │   ├── ArcheroCloneApp.swift        # SwiftUI entry point
│   │   └── ContentView.swift            # Hosts SpriteView
│   ├── Game/
│   │   ├── Constants.swift              # Physics categories, z-positions, tuning
│   │   ├── GameScene.swift              # Main SKScene — orchestrates gameplay
│   │   └── GameScene+Physics.swift      # Collision handling extension
│   ├── Nodes/
│   │   ├── PlayerNode.swift             # Player sprite + movement + shooting
│   │   ├── EnemyNode.swift              # Enemy sprite + chase AI
│   │   ├── BulletNode.swift             # Projectile sprite
│   │   └── JoystickNode.swift           # Virtual joystick overlay
│   ├── Managers/
│   │   └── WaveManager.swift            # Wave spawning logic
│   ├── UI/
│   │   ├── HUDNode.swift                # In-game health bar + score
│   │   └── GameOverOverlay.swift        # Game-over screen with restart
│   └── Extensions/
│       └── CGPoint+Helpers.swift        # Vector math helpers
├── ArcheroClone.xcodeproj/              # Xcode project (generated)
└── README.md
```

---

### Core Game Constants

#### [NEW] [Constants.swift](file:///Users/philiplin/Documents/projects/archero-clone/ArcheroClone/Game/Constants.swift)

- Physics category bitmasks (`player`, `enemy`, `bullet`, `boundary`)
- Z-position layers (`background`, `gameplay`, `hud`)
- Tuning constants: player speed, bullet speed, fire rate, enemy speed, spawn counts
- Arena size

---

### Player & Input

#### [NEW] [PlayerNode.swift](file:///Users/philiplin/Documents/projects/archero-clone/ArcheroClone/Nodes/PlayerNode.swift)

- `SKSpriteNode` subclass drawn as a colored square (placeholder art)
- `move(direction:)` called per frame from joystick input
- `autoShoot(enemies:)` — find nearest enemy, fire bullet toward it
- Health property with damage/death handling

#### [NEW] [JoystickNode.swift](file:///Users/philiplin/Documents/projects/archero-clone/ArcheroClone/Nodes/JoystickNode.swift)

- Transparent touch zone on the left half of the screen
- Tracks touch drag to produce a direction vector (normalized)
- Reports `isActive` and `direction` for the game scene to poll

---

### Enemies

#### [NEW] [EnemyNode.swift](file:///Users/philiplin/Documents/projects/archero-clone/ArcheroClone/Nodes/EnemyNode.swift)

- `SKSpriteNode` subclass (red square placeholder)
- Simple chase AI: move toward player position each frame
- HP property; destroyed on reaching 0

#### [NEW] [WaveManager.swift](file:///Users/philiplin/Documents/projects/archero-clone/ArcheroClone/Managers/WaveManager.swift)

- Tracks current wave number and enemies remaining
- `spawnWave(in scene:)` — spawns enemies at random edge positions
- Wave difficulty scaling (more enemies per wave)

---

### Projectiles & Combat

#### [NEW] [BulletNode.swift](file:///Users/philiplin/Documents/projects/archero-clone/ArcheroClone/Nodes/BulletNode.swift)

- Small yellow circle; moves in a straight line at constant speed
- Removed after hitting an enemy or leaving the screen
- Carries a `damage` value

#### [NEW] [GameScene+Physics.swift](file:///Users/philiplin/Documents/projects/archero-clone/ArcheroClone/Game/GameScene+Physics.swift)

- `SKPhysicsContactDelegate` implementation
- Handles: bullet↔enemy (deal damage, remove bullet), enemy↔player (deal damage to player)

---

### Game Scene

#### [NEW] [GameScene.swift](file:///Users/philiplin/Documents/projects/archero-clone/ArcheroClone/Game/GameScene.swift)

- Sets up arena boundary, player, joystick, HUD
- `update()` loop: poll joystick → move player → auto-shoot if idle → update enemies
- Delegates to `WaveManager` for spawning
- Handles game-over state transition

---

### HUD & UI

#### [NEW] [HUDNode.swift](file:///Users/philiplin/Documents/projects/archero-clone/ArcheroClone/UI/HUDNode.swift)

- Health bar (red/green rectangle pair)
- Score label (wave number + kill count)

#### [NEW] [GameOverOverlay.swift](file:///Users/philiplin/Documents/projects/archero-clone/ArcheroClone/UI/GameOverOverlay.swift)

- Semi-transparent overlay with "Game Over" text and score
- Tap-to-restart triggers scene reload

---

### App Shell (SwiftUI)

#### [NEW] [ArcheroCloneApp.swift](file:///Users/philiplin/Documents/projects/archero-clone/ArcheroClone/App/ArcheroCloneApp.swift)

- Standard SwiftUI `@main` app

#### [NEW] [ContentView.swift](file:///Users/philiplin/Documents/projects/archero-clone/ArcheroClone/App/ContentView.swift)

- Embeds `SpriteView(scene: GameScene(...))` full-screen, landscape

---

### Utilities

#### [NEW] [CGPoint+Helpers.swift](file:///Users/philiplin/Documents/projects/archero-clone/ArcheroClone/Extensions/CGPoint+Helpers.swift)

- `distance(to:)`, `normalized()`, vector arithmetic operators (`+`, `-`, `*`)

---

## Verification Plan

### Manual Verification (Xcode Simulator)

Since this is a new game project with no existing test infrastructure, verification will be done manually in the iOS Simulator:

1. **Open** `ArcheroClone.xcodeproj` in Xcode
2. **Build & Run** on an iPhone 15 Pro simulator (or any iPhone simulator)
3. **Test joystick**: Touch and drag on the left side of the screen — the player should move smoothly in all directions and stay within the arena
4. **Test auto-shoot**: Release the joystick — the player should automatically fire bullets at the nearest enemy
5. **Test enemies**: Enemies should spawn at screen edges and chase the player
6. **Test combat**: Bullets should destroy enemies on contact; enemies touching the player should reduce the health bar
7. **Test waves**: Clearing all enemies should spawn the next wave with more enemies
8. **Test game over**: When health reaches 0, game-over overlay appears; tapping restarts the game

> [!IMPORTANT]
> You'll need Xcode installed to build and run this. Please confirm you have Xcode available and let me know if you'd prefer any changes to the scope/mechanics before I start building.
