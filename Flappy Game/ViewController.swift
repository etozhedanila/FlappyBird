//
//  ViewController.swift
//  Flappy Game
//
//  Created by Виталий Субботин on 19/08/2019.
//  Copyright © 2019 Виталий Субботин. All rights reserved.
//

import UIKit
import SpriteKit
//import GameplayKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            let scene = GameScene(size: self.view.bounds.size)
            
            view.presentScene(scene)
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
        
    }


}

