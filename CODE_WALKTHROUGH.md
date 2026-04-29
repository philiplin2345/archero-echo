# Archero-Echo Code Walkthrough

Welcome to iOS game development! This document explains exactly what happens in the code from the moment you tap the app icon to the moment the "Game Over" screen appears.

## 1. App Launch (The Entry Point)
Every iOS app has a starting point. In this project, it's in **`AppDelegate.swift`**.

*   **`@main`**: This small attribute above the `AppDelegate` class tells iOS: "Start here."
*   **`application(_:didFinishLaunchingWithOptions:)`**: This is the very first function that runs. It handles high-level setup (like analytics or database initialization) before any screens appear.

## 2. Setting the Stage (The View Controller)
Once the app is running, it needs to show a screen. This is managed by **`GameViewController.swift`**.

*   **`viewDidLoad()`**: This runs once the "view" (the screen) is loaded into memory.
*   **Creating the Scene**: Inside `viewDidLoad`, we create a `GameScene`. 
    ```swift
    let scene = GameScene(size: skView.bounds.size)
    scene.scaleMode = .resizeFill
    scene.anchorPoint = CGPoint(x: 0.5, y: 0.5) // Sets (0,0) to the center of the screen
    skView.presentScene(scene) // Tells the screen to display our game
    ```

## 3. Entering the Game (The Scene Lifecycle)
Now we are in **`GameScene.swift`**, where the actual game logic lives.

*   **`didMove(to:)`**: This is like `viewDidLoad` but for SpriteKit scenes. It runs as soon as the scene is displayed.
    *   It calls helper functions like `setupPlayer()`, `setupJoystick()`, and `setupHUD()`.
    *   It sets up the physics world (`physicsWorld.gravity = .zero`).
*   **Starting Waves**: It starts a timer to spawn the first wave of enemies using the `WaveManager`.

## 4. The Heartbeat (The Game Loop)
Games don't just sit there; they update constantly.

*   **`update(_ currentTime:)`**: This function is called **60 times per second**.
    *   **Movement**: It checks if you are touching the `JoystickNode`. If you are, it moves the `PlayerNode`.
    *   **Combat**: If you *stop* moving, it calls `player.tryShoot()`.
    *   **Enemies**: It tells every `EnemyNode` to move toward the player's current position (`enemy.chase()`).

## 5. Collision & Combat
When a bullet hits an enemy or an enemy hits the player, SpriteKit's physics system takes over. This is handled in **`GameScene+Physics.swift`**.

*   **`didBegin(_ contact:)`**: This function triggers whenever two objects touch.
    *   If a **Bullet** touches an **Enemy**, the enemy takes damage.
    *   If an **Enemy** touches the **Player**, the player's HP decreases.

## 6. The End (Game Over)
If the player's health reaches zero:

1.  **`triggerGameOver()`** is called in `GameScene.swift`.
2.  The game "pauses" (`gameplayLayer.isPaused = true`).
3.  A **`GameOverOverlay`** is added to the screen.

## 7. Replaying
Inside **`GameOverOverlay.swift`**:

*   **`touchesBegan()`**: When you tap the screen, it creates a *brand new* `GameScene` and transitions to it. 
*   This resets the score, health, and waves, taking you back to **Step 3**.

---

### Key Concepts for Beginners
- **Nodes (`SKNode`)**: Everything you see (player, enemy, labels) is a "Node".
- **Actions (`SKAction`)**: Used for animations, like fading in a menu or moving a bullet.
- **Coordinate System**: Because we set the `anchorPoint` to `(0.5, 0.5)`, the center of your screen is `x: 0, y: 0`. Moving right increases `x`, moving up increases `y`.
