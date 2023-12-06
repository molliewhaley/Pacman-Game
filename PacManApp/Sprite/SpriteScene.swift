//
//  SpriteScene.swift
//  PacManApp
//
//  Created by Mollie Whaley on 12/5/23.
//

import SpriteKit
import SwiftUI

class SpriteScene: SKScene {

    @ObservedObject var restartVM: RestartGameVM
    
    private var userPausedGame: Bool = false
    private var nextDirection: CGVector? = nil
    
    private var scoreLabel: SKLabelNode!
    private var pacman: SKShapeNode! = nil
    private var pauseStateLabel: SKSpriteNode!
    
    private var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    enum CollisionMask: UInt32 {
        case dot = 1
        case wall = 2
        case pacman = 3
        case ghost = 4
    }
    
    init(restartVM: RestartGameVM, size: CGSize) {
        self.restartVM = restartVM
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Game Setup
    override func didMove(to view: SKView) {
        self.setupGame(to: view)
    }
    
    func setupGame(to view: SKView) {
        self.backgroundColor = UIColor.black
        
        self.createIcon()
        self.createMaze()
        self.createScoreLabel()
        self.createPauselabel()
        self.placeDotsOnPath()
        self.createRedGhost()
        self.createGreenGhost()
        self.createPacMan()
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipe(_:)))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipe(_:)))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(swipe(_:)))
        swipeUp.direction = .up
        view.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(swipe(_:)))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
    }
    
    //MARK: - Sprite Functions
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            
            if pauseStateLabel.contains(location) {
                if self.userPausedGame {
                    self.pauseStateLabel.texture = SKTexture(imageNamed: "pause")
                    self.pauseStateLabel.size = CGSize(width: 50, height: 45)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.playGame()
                    }
                } else {
                    self.pauseStateLabel.texture = SKTexture(imageNamed: "play")
                    self.pauseStateLabel.size = CGSize(width: 15, height: 15)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.pauseGame()
                    }
                }
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if let nextDirection = nextDirection {
            let nextPosition = CGPoint(x: pacman.position.x + nextDirection.dx,
                                       y: pacman.position.y + nextDirection.dy)
            let body = scene?.physicsWorld.body(at: nextPosition)
            
            if body?.categoryBitMask != CollisionMask.wall.rawValue {
                pacman.position = nextPosition
                self.turnPacmanAround()
            }
            
            if body?.categoryBitMask == CollisionMask.dot.rawValue {
                if countDotsOnScreen(scene: scene!) >= 1 {
                    body?.node?.removeFromParent()
                    score += 1
                }
                
                if countDotsOnScreen(scene: scene!) == 0 {
                    self.fullGameRestart()
                }
            }
            
            if body?.categoryBitMask == CollisionMask.ghost.rawValue {
                self.fullGameRestart()
            }
        }
    }
    
    //MARK: - Static Scene Nodes
    func createScoreLabel() {
        scoreLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        scoreLabel.fontSize = 18.0
        scoreLabel.fontColor = UIColor.white
        scoreLabel.text = "Score: 0"
        scoreLabel.position = CGPoint(x: 335, y: 725)
        addChild(scoreLabel)
    }
    
    func createPauselabel() {
        let texture = SKTexture(imageNamed: "pause")
        self.pauseStateLabel = SKSpriteNode(texture: texture)
        self.pauseStateLabel.size = CGSize(width: 50, height: 45)
        self.pauseStateLabel.color = SKColor.white
        self.pauseStateLabel.position = CGPoint(x: 40, y: 730)
        addChild(self.pauseStateLabel)
    }
    
    func createPlaylabel() {
        let texture = SKTexture(imageNamed: "play")
        self.pauseStateLabel = SKSpriteNode(texture: texture)
        self.pauseStateLabel.size = CGSize(width: 20, height: 15)
        self.pauseStateLabel.color = SKColor.white
        self.pauseStateLabel.position = CGPoint(x: 40, y: 730)
        addChild(self.pauseStateLabel)
    }
    
    func createIcon() {
        let imageNode = SKSpriteNode(imageNamed: "logo")
        imageNode.size = CGSize(width: 225, height: 115)
        imageNode.position = CGPoint(x: 195, y: 675)
        addChild(imageNode)
    }
    
    func placeDotsOnPath() {
        let dotPointsArray: [CGPoint] = [CGPoint(x: 125, y: 143), CGPoint(x: 160, y: 143), CGPoint(x: 193, y: 143), CGPoint(x: 230, y: 143), CGPoint(x: 263, y: 143), CGPoint(x: 300, y: 143), CGPoint(x: 332, y: 143), CGPoint(x: 125, y: 113), CGPoint(x: 125, y: 81), CGPoint(x: 125, y: 51), CGPoint(x: 90, y: 51), CGPoint(x: 55, y: 51), CGPoint(x: 55, y: 81), CGPoint(x: 55, y: 113), CGPoint(x: 55, y: 145), CGPoint(x: 55, y: 177), CGPoint(x: 55, y: 210), CGPoint(x: 55, y: 241), CGPoint(x: 55, y: 273), CGPoint(x: 55, y: 305), CGPoint(x: 55, y: 337), CGPoint(x: 55, y: 401), CGPoint(x: 55, y: 433), CGPoint(x: 55, y: 465), CGPoint(x: 55, y: 497), CGPoint(x: 55, y: 529), CGPoint(x: 55, y: 561), CGPoint(x: 55, y: 590), CGPoint(x: 87, y: 590), CGPoint(x: 119, y: 590), CGPoint(x: 119, y: 560), CGPoint(x: 119, y: 530), CGPoint(x: 119, y: 500), CGPoint(x: 153, y: 500), CGPoint(x: 193, y: 500), CGPoint(x: 226, y: 500), CGPoint(x: 263, y: 500), CGPoint(x: 300, y: 500), CGPoint(x: 332, y: 500), CGPoint(x: 332, y: 370), CGPoint(x: 263, y: 370), CGPoint(x: 263, y: 338), CGPoint(x: 263, y: 306), CGPoint(x: 263, y: 274), CGPoint(x: 263, y: 242), CGPoint(x: 263, y: 210), CGPoint(x: 263, y: 175), CGPoint(x: 263, y: 113), CGPoint(x: 263, y: 82), CGPoint(x: 263, y: 51), CGPoint(x: 298, y: 51), CGPoint(x: 332, y: 51), CGPoint(x: 332, y: 80), CGPoint(x: 332, y: 113), CGPoint(x: 332, y: 175), CGPoint(x: 332, y: 210), CGPoint(x: 332, y: 242), CGPoint(x: 332, y: 274), CGPoint(x: 332, y: 305), CGPoint(x: 300, y: 305), CGPoint(x: 300, y: 370), CGPoint(x: 332, y: 370), CGPoint(x: 332, y: 403), CGPoint(x: 332, y: 435), CGPoint(x: 332, y: 468), CGPoint(x: 263, y: 468), CGPoint(x: 263, y: 468), CGPoint(x: 263, y: 435), CGPoint(x: 263, y: 402), CGPoint(x: 226, y: 337), CGPoint(x: 193, y: 175), CGPoint(x: 193, y: 210), CGPoint(x: 193, y: 242), CGPoint(x: 193, y: 274), CGPoint(x: 193, y: 305), CGPoint(x: 193, y: 370), CGPoint(x: 193, y: 403), CGPoint(x: 193, y: 435), CGPoint(x: 193, y: 468), CGPoint(x: 332, y: 530), CGPoint(x: 332, y: 560), CGPoint(x: 332, y: 590), CGPoint(x: 297, y: 590), CGPoint(x: 263, y: 590), CGPoint(x: 263, y: 560), CGPoint(x: 263, y: 530), CGPoint(x: 227, y: 590), CGPoint(x: 193, y: 590), CGPoint(x: 193, y: 80), CGPoint(x: 193, y: 51), CGPoint(x: 226, y: 51), CGPoint(x: 153, y: 80), CGPoint(x: 159, y: 210), CGPoint(x: 124, y: 210), CGPoint(x: 124, y: 242), CGPoint(x: 124, y: 274), CGPoint(x: 124, y: 305), CGPoint(x: 90, y: 305), CGPoint(x: 158, y: 560), CGPoint(x: 193, y: 560), CGPoint(x: 158, y: 435), CGPoint(x: 124, y: 435), CGPoint(x: 124, y: 403), CGPoint(x: 124, y: 370), CGPoint(x: 90, y: 370), CGPoint(x: 55, y: 370)]
        
        for point in dotPointsArray {
            self.createDot(position: point)
        }
    }
    
    func createDot(position: CGPoint) {
        let dot = SKShapeNode(circleOfRadius: 5)
        
        dot.position = position
        
        dot.name = "dot"
        dot.strokeColor = .white
        dot.fillColor = .white
        
        let physicsBody = SKPhysicsBody(circleOfRadius: 20)
        
        physicsBody.isDynamic = false
        physicsBody.categoryBitMask = CollisionMask.dot.rawValue
        physicsBody.collisionBitMask = CollisionMask.pacman.rawValue
        
        dot.physicsBody = physicsBody
        
        addChild(dot)
    }
    
    //MARK: - Moveable Nodes
    func createGhost(text: String, position: CGPoint, speeds: [Double], waypoints: [CGPoint]) {
        let ghostNode = SKSpriteNode(texture: SKTexture(imageNamed: text))
        
        ghostNode.size = CGSize(width: 25, height: 25)
        ghostNode.position = position
        
        let physicsBody = SKPhysicsBody(rectangleOf: ghostNode.size)
        
        physicsBody.isDynamic = false
        physicsBody.categoryBitMask = CollisionMask.ghost.rawValue
        ghostNode.physicsBody = physicsBody
        
        addChild(ghostNode)
        
        self.moveGhost(
            usingGhost: ghostNode,
            waypoints: waypoints,
            speeds: speeds,
            index: 0
        )
    }
    
    func createRedGhost() {
        let redGhostSpeeds: [Double] = [2.0, 1.0, 2.0, 1.0, 1.0, 1.0, 1.0, 1.0, 3.5, 1.0, 0.5, 1.0, 0.5, 2.0, 3.5]
        let redGhostWaypoints: [CGPoint] = [
            CGPoint(x: 332, y: 370), CGPoint(x: 263, y: 370), CGPoint(x: 263, y: 500), CGPoint(x: 193, y: 500), CGPoint(x: 193, y: 435), CGPoint(x: 124, y: 435), CGPoint(x: 124, y: 370), CGPoint(x: 55, y: 370), CGPoint(x: 55, y: 590), CGPoint(x: 119, y: 590),  CGPoint(x: 119, y: 560), CGPoint(x: 193, y: 560), CGPoint(x: 193, y: 590), CGPoint(x: 332, y: 590), CGPoint(x: 332, y: 370)]
        
        self.createGhost(
            text: "red-ghost",
            position: CGPoint(x: 332, y: 500),
            speeds: redGhostSpeeds,
            waypoints: redGhostWaypoints
        )
    }
    
    func createGreenGhost() {
        let greenGhostSpeeds: [Double] = [2.0, 1.5, 1.0, 4.0, 1.0, 0.5, 1.0, 2.0, 1.0, 2.0, 1.0, 4.0, 1.0, 1.5]
        let greenGhostWaypoints: [CGPoint] = [CGPoint(x: 263, y: 143), CGPoint(x: 263, y: 45), CGPoint(x: 332, y: 45), CGPoint(x: 332, y: 305), CGPoint(x: 263, y: 305), CGPoint(x: 263, y: 335), CGPoint(x: 193, y: 335), CGPoint(x: 193, y: 210), CGPoint(x: 124, y: 210), CGPoint(x: 124, y: 305), CGPoint(x: 55, y: 305), CGPoint(x: 55, y: 48), CGPoint(x: 125, y: 48), CGPoint(x: 125, y: 143)]
        
        self.createGhost(
            text: "green-ghost",
            position: CGPoint(x: 125, y: 143),
            speeds: greenGhostSpeeds,
            waypoints: greenGhostWaypoints
        )
    }
    
    func createPacMan() {
        pacman = SKShapeNode(circleOfRadius: 10)
        
        pacman.fillColor = UIColor(Color("pacman-yellow"))
        pacman.strokeColor = UIColor(Color("pacman-yellow"))
        pacman.position = CGPoint(x: 195, y: 337)
        
        let mouthPath = CGMutablePath()
        
        mouthPath.move(to: .zero)
        mouthPath.addArc(
            center: .zero,
            radius: 12,
            startAngle: .pi / 6,
            endAngle: 11 * .pi / 6,
            clockwise: false
        )
        mouthPath.closeSubpath()
        
        pacman.path = mouthPath
        
        pacman.physicsBody?.categoryBitMask = CollisionMask.pacman.rawValue
        
        addChild(pacman)
    }
    
    func createMaze() {
        enum MazeCell {
            case wall
            case pathway
        }
        
        let mazeLayout: [[MazeCell]] = [
            [.wall, .wall, .wall, .wall, .wall, .wall, .wall, .wall, .wall, .wall, .wall],
            [.wall, .pathway, .pathway, .pathway, .wall, .pathway, .pathway, .pathway, .pathway, .pathway, .wall],
            [.wall, .pathway, .wall, .pathway, .pathway, .pathway, .wall, .pathway, .wall, .pathway, .wall],
            [.wall, .pathway, .wall, .pathway, .wall, .wall, .wall, .pathway, .wall, .pathway, .wall],
            [.wall, .pathway, .wall, .pathway, .pathway, .pathway, .pathway, .pathway, .pathway, .pathway, .wall],
            [.wall, .pathway, .wall, .wall, .wall, .pathway, .wall, .pathway, .wall, .pathway, .wall],
            [.wall, .pathway, .wall, .pathway, .pathway, .pathway, .wall, .pathway, .wall, .pathway, .wall],
            [.wall, .pathway, .wall, .pathway, .wall, .pathway, .wall, .pathway, .wall, .pathway, .wall],
            [.wall, .pathway, .wall, .pathway, .wall, .pathway, .wall, .pathway, .wall, .pathway, .wall],
            [.wall, .pathway, .pathway, .pathway, .wall, .pathway, .wall, .pathway, .pathway, .pathway, .wall],
            [.wall, .pathway, .wall, .wall, .wall, .pathway, .pathway, .pathway, .wall, .wall, .wall],
            [.wall, .pathway, .pathway, .pathway, .wall, .pathway, .wall, .pathway, .pathway, .pathway, .wall],
            [.wall, .pathway, .wall, .pathway, .wall, .pathway, .wall, .pathway, .wall, .pathway, .wall],
            [.wall, .pathway, .wall, .pathway, .pathway, .pathway, .wall, .pathway, .wall, .pathway, .wall],
            [.wall, .pathway, .wall, .wall, .wall, .pathway, .wall, .pathway, .wall, .pathway, .wall],
            [.wall, .pathway, .wall, .pathway, .pathway, .pathway, .pathway, .pathway, .pathway, .pathway, .wall],
            [.wall, .pathway, .wall, .pathway, .wall, .wall, .wall, .pathway, .wall, .pathway, .wall],
            [.wall, .pathway, .wall, .pathway, .pathway, .pathway, .wall, .pathway, .wall, .pathway, .wall],
            [.wall, .pathway, .pathway, .pathway, .wall, .pathway, .pathway, .pathway, .pathway, .pathway, .wall],
            [.wall, .wall, .wall, .wall, .wall, .wall, .wall, .wall, .wall, .wall, .wall]
        ]
        
        for (row, rowData) in mazeLayout.enumerated() {
            for (col, cell) in rowData.enumerated() {
                
                let wallHeight: Int = Int(UIScreen.main.bounds.width) / 12
                let wallWidth: Int = Int(UIScreen.main.bounds.width) / 11
                let cellRectangle = CGRect(x: col * wallWidth, y: row * wallHeight, width: wallWidth, height: wallHeight)
                
                switch cell {
                case .wall:
                    createWall(at: cellRectangle)
                    
                case .pathway:
                    createPathway(at: cellRectangle)
                }
            }
        }
    }
    
    func createWall(at rectangle: CGRect) {
        let wall = SKSpriteNode(color: .black, size: CGSize(width: rectangle.width, height: rectangle.height))
        wall.position = CGPoint(x: rectangle.midX, y: rectangle.midY)
        
        let physicsBodySize = CGSize(width: Double(rectangle.width) * 1.58, height: Double(rectangle.height) * 1.58)
        let physicsBody = SKPhysicsBody(rectangleOf: physicsBodySize)
        
        wall.physicsBody = physicsBody
        wall.physicsBody?.isDynamic = false
        wall.physicsBody?.categoryBitMask = CollisionMask.wall.rawValue
        
        addChild(wall)
    }
    
    func createPathway(at rectangle: CGRect) {
        let pathwayNode = SKShapeNode(rect: rectangle)
        
        pathwayNode.fillColor = .black
        pathwayNode.strokeColor = .blue
        pathwayNode.lineWidth = 6
        
        addChild(pathwayNode)
    }
    
    //MARK: - Game States
    func playGame() {
        self.userPausedGame = false
        scene?.view?.isPaused = false
    }
    
    func pauseGame() {
        self.userPausedGame = true
        scene?.view?.isPaused = true
    }
    
    func fullGameRestart() {
        nextDirection = nil
        self.removeAllChildren()
        restartVM.restartGame()
    }
    
    //MARK: - Moving Nodes + User Interaction
    func turnPacmanAround() {
        if let nextDirection = nextDirection {
            
            let angle = atan2(nextDirection.dy, nextDirection.dx)
            let rotateAction = SKAction.rotate(toAngle: angle, duration: 0.20)
            
            pacman.run(rotateAction)
        }
    }
    
    func moveGhost(usingGhost ghost: SKSpriteNode, waypoints: [CGPoint], speeds: [Double], index: Int) {
        var nextIndex: Int = index + 1
        let moveToWaypoint: SKAction = SKAction.move(to: waypoints[index], duration: speeds[index])
        
        ghost.run(moveToWaypoint) {
            if index >= waypoints.count - 1 {
                nextIndex = 0
            }
            self.moveGhost(usingGhost: ghost, waypoints: waypoints, speeds: speeds, index: nextIndex)
        }
    }
    
    @objc func swipe(_ gesture: UISwipeGestureRecognizer) {
        switch gesture.direction {
        case .right:
            self.nextDirection = CGVector(dx: 1, dy: 0)
        case .left:
            self.nextDirection = CGVector(dx: -1, dy: 0)
        case .up:
            self.nextDirection = CGVector(dx: 0, dy: 1)
        case .down:
            self.nextDirection = CGVector(dx: 0, dy: -1)
        default:
            break
        }
    }
    
    //MARK: - Additional Functions
    func countDotsOnScreen(scene: SKScene) -> Int {
        var dotCount: Int = 0
        
        for node in self.children {
            if node.name == "dot" {
                dotCount += 1
            }
        }
        
        return dotCount
    }
}
