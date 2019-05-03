//
//  GameViewController.swift
//  SchoolHouseSkateboarder
//
//  Created by Student on 4/1/19.
//  Copyright © 2019 Student. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
//        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
//        
//        leftSwipe.direction = .left
//        rightSwipe.direction = .right
//        
//        view.addGestureRecognizer(leftSwipe)
//        view.addGestureRecognizer(rightSwipe)
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                let width = view.bounds.width
                let height = view.bounds.height
                scene.size = CGSize (width: width, height: height)
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
//    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
//
//        if (sender.direction == .left) {
//            print("Swipe Left")
//            let labelPosition = CGPoint(x: swipeLabel.frame.origin.x - 50.0, y: swipeLabel.frame.origin.y)
//            swipeLabel.frame = CGRect(x: labelPosition.x, y: labelPosition.y, width: swipeLabel.frame.size.width, height: swipeLabel.frame.size.height)
//        }
//
//        if (sender.direction == .right) {
//            print("Swipe Right")
//            let labelPosition = CGPoint(x: self.swipeLabel.frame.origin.x + 50.0, y: self.swipeLabel.frame.origin.y)
//            swipeLabel.frame = CGRect(x: labelPosition.x, y: labelPosition.y, width: self.swipeLabel.frame.size.width, height: self.swipeLabel.frame.size.height)
//        }
//    }
}
