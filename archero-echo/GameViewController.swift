//
//  GameViewController.swift
//  archero-echo
//
//  Created by Philip Lin on 2026/4/25.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let skView = self.view as? SKView else { return }
        
        // Create the game scene programmatically (not from .sks file)
        let scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .resizeFill
        scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)  // Center origin
        
        skView.presentScene(scene)
        
        // Debug info (disable for release)
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        
        // Performance
        skView.shouldCullNonVisibleNodes = true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait  // Archero is portrait-mode
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
}
