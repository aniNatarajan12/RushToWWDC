//
//  ViewController.swift
//  background
//
//  Created by Anirudh Natarajan on 3/31/18.
//  Copyright © 2018 Anirudh Natarajan. All rights reserved.
//

import UIKit
import SpriteKit
import SceneKit

public class ViewController: UIViewController {
    
    public override func loadView() {
        self.view = SKView()
    }
    
    // present the welcome scene
    public override func viewDidLoad() {
        super.viewDidLoad()
        let scene = GameView(size: CGSize(width: 600, height: 880))
        
        let skView = self.view as! SKView
        scene.scaleMode = .aspectFit
        
        skView.presentScene(scene)
    }

    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}


