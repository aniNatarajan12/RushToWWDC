//
//  GameViewController.swift
//  RushToWWDC
//
//  Created by Anirudh Natarajan on 3/30/18.
//  Copyright © 2018 Anirudh Natarajan. All rights reserved.
//

import UIKit
import ARKit
import SpriteKit
import SceneKit
import AVFoundation

struct PhysicsMask {
    static let playerBullet = 0
    static let enemyBullet = 1
    static let enemy = 2
}

enum LaserType  {
    case player
    case enemy
}

public class GameViewController: UIViewController, GameDelegate, ARSCNViewDelegate, ARSessionDelegate{

    let session = ARSession()
    var sceneView : ARSCNView!
    
    var aliens = [AlienNode]()
    var lasers = [LaserNode]()
    public var game = Game()
    
    // font things
    
    lazy var paragraphStyle : NSParagraphStyle = {
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.left
        return style
    }()
    
    lazy var stringAttributes : [NSAttributedStringKey : Any] = [.strokeColor : UIColor.black, .strokeWidth : -4, .foregroundColor: UIColor.white, .font : UIFont.systemFont(ofSize: 23, weight: .bold), .paragraphStyle : paragraphStyle]
    
    // Nodes for the UI
    var scoreNode : SKLabelNode!
    var livesNode : SKLabelNode!
    var radarNode : SKShapeNode!
    var crosshair: SKSpriteNode!
    
    let sidePadding : CGFloat = 5

    
    //MARK: GameDelegate Functions
    
    func scoreDidChange() {
        scoreNode.attributedText = NSMutableAttributedString(string: "Enemies: \(game.totalAliens - game.score)", attributes: stringAttributes)
        if game.score >= game.totalAliens {
            game.winLoseFlag = true
            showFinish()
        }
    }
    
    func healthDidChange() {
        
        // change the number to emojis
        var i = 0
        var healthEmoji = ""
        while i<game.health {
            i = i+1
            healthEmoji += "♥️"
        }
        livesNode.attributedText = NSAttributedString(string: "Health: \(healthEmoji)", attributes: stringAttributes)
        if game.health <= 0 {
            game.winLoseFlag = false
            showFinish()
        }
    }
    
    
    //MARK: View Controller Lifecycle

    override public func viewDidLoad() {
        super.viewDidLoad()
        game.delegate = self
        setupAR()
        setupGestureRecognizers()
        setupScene()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    //Mark: UI Setup
    
    private func setupAR() {
        // setup the AR stuff
        
        sceneView = ARSCNView(frame: CGRect(x: 0.0, y: 0.0, width: 475.0, height: 740.0))
        
        let scene = SCNScene()
        sceneView.scene = scene
        
        let config = ARWorldTrackingConfiguration()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.session = session
        
        sceneView.session.delegate = self
        
        self.view = sceneView
        sceneView.session.run(config)
    }
    
    private func setupScene() {
        // setup the scene... pretty self-explanatory :D
        sceneView.delegate = self
        sceneView.scene = SCNScene()
        sceneView.scene.physicsWorld.contactDelegate = self
        sceneView.overlaySKScene = SKScene(size: sceneView.bounds.size)
        sceneView.overlaySKScene?.scaleMode = .resizeFill
        setupLabels()
        setupRadar()
    }
    
    private func setupGestureRecognizers() {
        // add tap recognizer
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        
        tapRecognizer.numberOfTouchesRequired = 1
        
        sceneView.addGestureRecognizer(tapRecognizer)
    }
    
    private func setupRadar() {
        let size = sceneView.bounds.size
        
        // radar background
        radarNode = SKShapeNode(circleOfRadius: 40)
        radarNode.position = CGPoint(x: 475 - 40 - sidePadding, y: 50 + sidePadding)
        radarNode.strokeColor = .black
        radarNode.glowWidth = 5
        radarNode.fillColor = .white
        sceneView.overlaySKScene?.addChild(radarNode)
        
        // radar design
        for i in (1...3){
            let ringNode = SKShapeNode(circleOfRadius: CGFloat(i * 10))
            ringNode.strokeColor = .black
            ringNode.glowWidth = 0.2
            ringNode.name = "Ring"
            ringNode.position = radarNode.position
            sceneView.overlaySKScene?.addChild(ringNode)
        }
        
        //blips for each alien
        for _ in (0..<(game.totalAliens)){
            let blip = SKShapeNode(circleOfRadius: 5)
            blip.fillColor = .red
            blip.strokeColor = .clear
            blip.alpha = 0
            radarNode.addChild(blip)
        }
        
    }
    
    private func setupLabels() {
        
        // setup the UI
        let size = sceneView.bounds

        scoreNode = SKLabelNode(attributedText: NSAttributedString(string: "Enemies: \(game.totalAliens - game.score)", attributes: stringAttributes))
        scoreNode.alpha = 1
        
        var i = 0
        var healthEmoji = ""
        while i<game.health {
            i = i+1
            healthEmoji += "♥️"
        }
        livesNode = SKLabelNode(attributedText: NSAttributedString(string: "Health: \(healthEmoji)", attributes: stringAttributes))
        livesNode.alpha = 1
        
        crosshair = SKSpriteNode(imageNamed: "Crosshair.png")
        crosshair.size = CGSize(width: 25, height: 25)
        crosshair.alpha = 1
        
        scoreNode.position = CGPoint(x: sidePadding + livesNode.frame.width + 80, y: 30 + sidePadding)
        scoreNode.horizontalAlignmentMode = .center
        livesNode.position = CGPoint(x: sidePadding, y: 30 + sidePadding)
        livesNode.horizontalAlignmentMode = .left
        crosshair.position = CGPoint(x: size.midX, y: size.midY)
        
        
        sceneView.overlaySKScene?.addChild(scoreNode)
        sceneView.overlaySKScene?.addChild(livesNode)
        sceneView.overlaySKScene?.addChild(crosshair)
    }
    
    private func showFinish() {
        guard let hasWon = game.winLoseFlag else { return }
        
        // present the AR text
        let text = SCNText(string: hasWon ? "You Saved The Day! Onward to WWDC!" : "Aww, Try Again!", extrusionDepth: 0.5)
        let material = SCNMaterial()
        material.diffuse.contents = hasWon ? UIColor.green : UIColor.red
        
        // make the text appear on multiple lines
        text.isWrapped = true
        text.containerFrame = CGRect(origin: .zero, size: CGSize(width: 100.0, height: 400.0))
        text.materials = [material]
        
        let node = SCNNode()
        node.simdPosition = simd_float3((sceneView.pointOfView?.simdPosition.x)!, (sceneView.pointOfView?.simdPosition.y)! - 2.8, (sceneView.pointOfView?.simdPosition.z)!) + sceneView.pointOfView!.simdWorldFront * 0.5
        node.simdRotation = sceneView.pointOfView!.simdRotation
        node.scale = SCNVector3(x: 0.007, y: 0.007, z: 0.007)
        node.geometry = text
        
        sceneView.scene.rootNode.addChildNode(node)
    }
    
    //Mark: UI Gesture Actions

    @objc func handleTap(recognizer: UITapGestureRecognizer){
        // if the player taps the screen, shoot!
        if game.playerCanShoot() {
            fireLaser(fromNode: sceneView.pointOfView!, type: .player)
        }
    }
    
    //MARK: Game Actions
    
    func fireLaser(fromNode node: SCNNode, type: LaserType){
        guard game.winLoseFlag == nil else { return }
        let pov = sceneView.pointOfView!
        var position: SCNVector3
        var convertedPosition: SCNVector3
        var direction : SCNVector3
        switch type {
            
        case .enemy:
            // If enemy, shoot at the player
            position = SCNVector3Make(0, 0, 0.05)
            convertedPosition = node.convertPosition(position, to: nil)
            direction = pov.position - node.position
        default:
            // play the sound effect
            self.playSoundEffect(ofType: .torpedo)
            // if player, shoot straight ahead
            position = SCNVector3Make(0, 0, -0.05)
            convertedPosition = node.convertPosition(position, to: nil)
            direction = convertedPosition - pov.position
        }
        
        let laser = LaserNode(initialPosition: convertedPosition, direction: direction, type: type)
        lasers.append(laser)
        sceneView.scene.rootNode.addChildNode(laser.node)
    }
    
    private func spawnAlien(alien: Alien){
        let pov = sceneView.pointOfView!
        let y = (Float(arc4random_uniform(60)) - 29) * 0.01 // Random Y value between -0.3 and 0.3
        
        //Random X and Z values for the alien
        let xRad = ((Float(arc4random_uniform(361)) - 180)/180) * Float.pi
        let zRad = ((Float(arc4random_uniform(361)) - 180)/180) * Float.pi
        let length = Float(arc4random_uniform(6) + 4) * -0.3
        let x = length * sin(xRad)
        let z = length * cos(zRad)
        let position = SCNVector3Make(x, y, z)
        let worldPosition = pov.convertPosition(position, to: nil)
        let alienNode = AlienNode(alien: alien, position: worldPosition, cameraPosition: pov.position)
        
        aliens.append(alienNode)
        sceneView.scene.rootNode.addChildNode(alienNode.node)
    }
    
    // MARK: - Sound Effects
    
    var player: AVAudioPlayer!
    
    func playSoundEffect(ofType effect: SoundEffect) {
        
        // Async to decrease processing power needed
        DispatchQueue.main.async {
            do {
                if let effectURL = Bundle.main.url(forResource: effect.rawValue, withExtension: "mp3") {
                    self.player = try AVAudioPlayer(contentsOf: effectURL)
                    self.player.play()
                }
            }
            catch let error as NSError {
                print(error.description)
            }
        }
    }

}

enum SoundEffect: String {
    case explosion = "explosion"
    case collision = "collision"
    case torpedo = "torpedo"
}

//MARK: Scene Physics Contact Delegate

extension GameViewController : SCNPhysicsContactDelegate {
    
    public func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        let maskA = contact.nodeA.physicsBody!.contactTestBitMask
        let maskB = contact.nodeB.physicsBody!.contactTestBitMask

        switch(maskA, maskB){
        case (PhysicsMask.enemy, PhysicsMask.playerBullet):
            self.playSoundEffect(ofType: .collision)
            hitEnemy(bullet: contact.nodeB, enemy: contact.nodeA)
            self.playSoundEffect(ofType: .collision)
        case (PhysicsMask.playerBullet, PhysicsMask.enemy):
            self.playSoundEffect(ofType: .collision)
            hitEnemy(bullet: contact.nodeA, enemy: contact.nodeB)
        default:
            break
        }
    }
    
    func hitEnemy(bullet: SCNNode, enemy: SCNNode){
        
        self.playSoundEffect(ofType: .explosion)
        
        let particleSystem = SCNParticleSystem(named: "explosion", inDirectory: nil)
        let systemNode = SCNNode()
        systemNode.addParticleSystem(particleSystem!)
        systemNode.scale = SCNVector3(x: 0.05, y: 0.05, z: 0.05)
        systemNode.position = bullet.position
        sceneView.scene.rootNode.addChildNode(systemNode)
        
        bullet.removeFromParentNode()
        enemy.removeFromParentNode()
        game.score += 1
    }
}

//MARK: AR SceneView Delegate
extension GameViewController{
    public func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard game.winLoseFlag == nil else { return }

        // Let Game spawn an alien
        if let alien = game.spawnAlien(numAliens: aliens.count){
            spawnAlien(alien: alien)
        }
        
        for (i, alien) in aliens.enumerated().reversed() {
            
            // If the alien no longer exists, remove it from the list
            guard alien.node.parent != nil else {
                aliens.remove(at: i)
                continue
            }
            
            // move the alien towards to player
            if alien.move(towardsPosition: sceneView.pointOfView!.position) == false {
                // if the alien can't move closer, it crashes into the player
                alien.node.removeFromParentNode()
                aliens.remove(at: i)
                game.health -= alien.alien.health
            }else {
            
                if alien.alien.shouldShoot() {
                    fireLaser(fromNode: alien.node, type: .enemy)
                }
            }
        }
        
        // Draw aliens on the radar as an XZ Plane
        for (i, blip) in radarNode.children.enumerated() {
            if i < aliens.count {
                let alien = aliens[i]
                blip.alpha = 1
                let relativePosition = sceneView.pointOfView!.convertPosition(alien.node.position, from: nil)
                var x = relativePosition.x * 10
                var y = relativePosition.z * -10
                if x >= 0 { x = min(x, 35) } else { x = max(x, -35)}
                if y >= 0 { y = min(y, 35) } else { y = max(y, -35)}
                blip.position = CGPoint(x: CGFloat(x), y: CGFloat(y))
            }else{
                // If the alien hasn't spawned yet, hide the blip
                blip.alpha = 0
            }
            
        }
        
        for (i, laser) in lasers.enumerated().reversed() {
            if laser.node.parent == nil {
                // If the bullet no longer exists, remove it from the list
                lasers.remove(at: i)
            }
            // move the laser
            if laser.move() == false {
                laser.node.removeFromParentNode()
                lasers.remove(at: i)
            } else {
                // Check if the bullet hit the player
                if laser.node.physicsBody?.contactTestBitMask == PhysicsMask.enemyBullet
                    && laser.node.position.distance(vector: sceneView.pointOfView!.position) < 0.03{
                    laser.node.removeFromParentNode()
                    lasers.remove(at: i)
                    game.health -= 1
                }
            }
        }
    }

}

