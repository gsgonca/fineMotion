//
//  pinchGameScene.swift
//  fineMotion
//
//  Created by Gabriel Santos Gonçalves on 16/01/26.
//
//


                    
import SpriteKit
import SwiftUI

class GameScene: SKScene, @preconcurrency SKPhysicsContactDelegate {
    
/// Variables used to create, draw and close both paths. This turns them into closed shapes.
// TODO: The way paths are made causes collision problems and should be refactored.
    var leftPath: UIBezierPath!
    var rightPath: UIBezierPath!
    
/// Stores all nodes created in both paths in .didMove and uses them to check for collision in .update
    var leftPathNodes: [SKShapeNode] = []
    var rightPathNodes: [SKShapeNode] = []
    
    @State var repeatPath = 2
    var pathHeight: CGFloat = 0
    
/// Creates both controllers.
    let circleL = SKShapeNode(circleOfRadius: 40)
    let circleR = SKShapeNode(circleOfRadius: 40)
    
    struct PhysicsCategory {
        static let Controllers: UInt32 = 1
        static let Lines: UInt32 = 1
    }
    
/// Recognizes where a touch happens on the screen and stores the position as a SKNode.
    var activeTouches = [UITouch: SKNode]()
    
    var isGamePaused = false
    
/// Changes its value based on where the controllers are positioned on the screen.
    var leftTouchingPath = false
    var rightTouchingPath = false

    func pauseGame() {
        isGamePaused = true
    }
    
    func resumeGame() {
        isGamePaused = false
    }
    
    override func didMove(to view: SKView) {
        /// Enable multiple touches, this is crucial for the game to work.
        view.isMultipleTouchEnabled = true
        /// Sets physics and collision in the game
        self.physicsWorld.contactDelegate = self
        /// Sets the screen height to its full vertical size, we use this to loop both paths.
        let screenHeight = self.size.height
        
        ///Creates and positions the left path.
        leftPath = UIBezierPath()
        leftPath.move(to: CGPoint(x: 100, y: 0))
        leftPath.addLine(to: CGPoint(x: 200, y: screenHeight * 0.25))
        leftPath.addLine(to: CGPoint(x: 100, y: screenHeight * 0.50))
        leftPath.addLine(to: CGPoint(x: 200, y: screenHeight * 0.75))
        leftPath.addLine(to: CGPoint(x: 100, y: screenHeight))
        
        ///Creates and positions the right path.
        rightPath = UIBezierPath()
        rightPath.move(to: CGPoint(x: 292, y: 0))
        rightPath.addLine(to: CGPoint(x: 200, y: screenHeight * 0.25))
        rightPath.addLine(to: CGPoint(x: 292, y: screenHeight * 0.50))
        rightPath.addLine(to: CGPoint(x: 200, y: screenHeight * 0.75))
        rightPath.addLine(to: CGPoint(x: 292, y: screenHeight))
        
        ///Sets the pathHeight to be the value between the bottom and top sides on the leftPath boundingBox, we use this to offset the repeating subsequent paths.
        pathHeight = leftPath.cgPath.boundingBox.height
        
        /// Creates repeated paths and offsets them in the y axis by their height, creating a visual loop.
        for i in 0..<repeatPath {
            let leftNode = createPathNode(path: leftPath, physicsCategory: PhysicsCategory.Lines, contactCategory: PhysicsCategory.Controllers)
            let rightNode = createPathNode(path: rightPath, physicsCategory: PhysicsCategory.Lines, contactCategory: PhysicsCategory.Controllers)
            let yOffset = CGFloat(i) * pathHeight
            
            leftNode.position = CGPoint(x: 0,y: yOffset)
            rightNode.position = CGPoint(x: 0,y: yOffset)
            
            addChild(leftNode)
            addChild(rightNode)
            
            leftPathNodes.append(leftNode)
            rightPathNodes.append(rightNode)
        }
        setupControllers()
    }
    
/// Customizes how the path works on it's enviroment and it's style.
    func createPathNode(path: UIBezierPath, physicsCategory: UInt32, contactCategory: UInt32) -> SKShapeNode {
        let body = SKPhysicsBody(polygonFrom: path.cgPath)
        body.isDynamic = false
        body.affectedByGravity = false
        body.categoryBitMask = physicsCategory
        body.contactTestBitMask = contactCategory
        
        let shape = SKShapeNode(path: path.cgPath)
        shape.strokeColor = .cyan
        shape.lineWidth = 30
        shape.lineCap = .round
        shape.lineJoin = .round
        shape.physicsBody = body
        shape.zPosition = 0
        
        return shape
    }
    
    func setupControllers() {
        circleL.fillColor = UIColor.blue
        circleL.position = CGPoint(x: 90, y: 380)
        circleL.name = "circleL"
        circleL.physicsBody = SKPhysicsBody(circleOfRadius: 40)
        circleL.physicsBody?.affectedByGravity = false
        circleL.physicsBody?.isDynamic = false
        circleL.physicsBody?.categoryBitMask = PhysicsCategory.Controllers
        circleL.physicsBody?.contactTestBitMask = PhysicsCategory.Lines
        circleL.zPosition = 10
        addChild(circleL)
        
        circleR.fillColor = UIColor.blue
        circleR.position = CGPoint(x: 310, y: 380)
        circleR.name = "circleR"
        circleR.physicsBody = SKPhysicsBody(circleOfRadius: 40)
        circleR.physicsBody?.affectedByGravity = false
        circleR.physicsBody?.isDynamic = false
        circleR.physicsBody?.categoryBitMask = PhysicsCategory.Controllers
        circleR.physicsBody?.contactTestBitMask = PhysicsCategory.Lines
        circleR.zPosition = 10
        addChild(circleR)
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        let tolerance: CGFloat = 20
        
        leftTouchingPath = isController(circleL, nearPathNodes: leftPathNodes, tolerance: tolerance)
        rightTouchingPath = isController(circleR, nearPathNodes: rightPathNodes, tolerance: tolerance)
        
        if leftTouchingPath && rightTouchingPath {
            isGamePaused = false
        } else {
            isGamePaused = true
        }
        
        if isGamePaused { return }
        
        let speed: CGFloat = 250
        let deltaY = speed / 60
        
        for node in leftPathNodes {
            node.position.y -= deltaY
            if node.position.y <= -pathHeight {
                node.position.y += pathHeight * CGFloat(repeatPath)
            }
        }
        
        for node in rightPathNodes {
            node.position.y -= deltaY
            
            if node.position.y <= -pathHeight {
                node.position.y += pathHeight * CGFloat(repeatPath)
            }
        }
    }
    
    func isController(_ controller: SKShapeNode, nearPathNodes nodes: [SKShapeNode], tolerance: CGFloat) -> Bool {
        for node in nodes {
            let nodeFrame = node.frame
            if nodeFrame.insetBy(dx: -tolerance, dy: -tolerance).contains(controller.position) {
                return true
            }
        }
        return false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let node = atPoint(location)
            
            if node.name == "circleL" || node.name == "circleR" {
                activeTouches[touch] = node
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            if let node = activeTouches[touch] {
                node.position = touch.location(in: self)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            activeTouches.removeValue(forKey: touch)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }
    
    @MainActor func didBegin(_ contact: SKPhysicsContact) {
        let a = contact.bodyA.categoryBitMask
        let b = contact.bodyB.categoryBitMask
        
        if (a == PhysicsCategory.Controllers && b == PhysicsCategory.Lines) ||
            (a == PhysicsCategory.Lines && b == PhysicsCategory.Controllers) {
            leftTouchingPath = true
        }
        if (a == PhysicsCategory.Controllers && b == PhysicsCategory.Lines) ||
            (a == PhysicsCategory.Lines && b == PhysicsCategory.Controllers) {
            rightTouchingPath = true
        }
        if leftTouchingPath && rightTouchingPath {
            resumeGame()
        }
    }
        
        @MainActor func didEnd(_ contact: SKPhysicsContact) {
            let a = contact.bodyA.categoryBitMask
            let b = contact.bodyB.categoryBitMask
            
            if (a == PhysicsCategory.Controllers && b == PhysicsCategory.Lines) ||
                (a == PhysicsCategory.Lines && b == PhysicsCategory.Controllers) {
                leftTouchingPath = false
                pauseGame()
            }
            
            if (a == PhysicsCategory.Controllers && b == PhysicsCategory.Lines) ||
                (a == PhysicsCategory.Lines && b == PhysicsCategory.Controllers) {
                rightTouchingPath = false
                pauseGame()
            }
        }
    }
