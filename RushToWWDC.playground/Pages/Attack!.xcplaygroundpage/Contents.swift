/*:
 
 ## You're Under Attack
 It's all up to you to save the Earth. Use your camera to look around for aliens. Line up the aliens with your crosshair and **tap** the screen to shoot.
 
 *Be aware of you surroundings!* Aliens will appear from any direction so make sure you are **standing up** and in an open area.
 
 Oh, I almost forgot the mention. Make sure you are checking your **radar** as it will tell you exactly where each alien is. Nifty isn't it!
 
 Alright soldier, that's all the info I have for you. Good luck and kick some alien butt!
 
 
 ### If the mission proves too difficult
 Mess around with some of the values below
 */

// Total number of aliens you have to fight
var totalAliens = 10

// Increase this number if you want aliens to spawn less often
var spawnFreq = 90

// Increase this number if you want aliens to shoot less often
var shotFreq = 90






























// same...

import PlaygroundSupport
import UIKit

let viewController = GameViewController()
viewController.game.spawnFreq = spawnFreq
viewController.game.totalAliens = totalAliens
viewController.game.shotFreq = shotFreq

// Present the ViewController
PlaygroundPage.current.liveView = viewController

// Tells the Playground needsIndefiniteExecution
PlaygroundPage.current.needsIndefiniteExecution = true

