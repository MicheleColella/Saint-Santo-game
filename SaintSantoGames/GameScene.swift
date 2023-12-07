import SpriteKit

enum CutDirection {
    case any, leftToRight, rightToLeft, topToBottom, bottomToTop
}

class Note: SKSpriteNode {
    var isCut: Bool = false
    var cutDirection: CutDirection = .any // Direzione di taglio predefinita
    var cubeTexture: SKTexture = SKTexture() // Texture per il cubo della nota
}

class GameScene: SKScene {
    var scoreLabel: SKLabelNode!

    var notes: [Note] = []
    var score: Int = 0
    var bpm: Double = 120.0
    let columnSequence = [0, 2, 1, 1, 0, 2, 0, 2, 1, 1, 1, 1, 0]
 // Sequenza di colonne personalizzate
    let cutDirections: [CutDirection] = [.leftToRight, .rightToLeft, .topToBottom, .rightToLeft, .leftToRight, .leftToRight, .leftToRight, .rightToLeft, .leftToRight, .bottomToTop, .bottomToTop, .topToBottom, .bottomToTop] // Array delle direzioni di taglio
    let distanceBetweenNotes: CGFloat = 60
    let noteWidth: CGFloat = 120 // Larghezza fissa delle note
    let noteHeight: CGFloat = 120 // Altezza fissa delle note
    let verticalDistanceBetweenNotes: CGFloat = 250 // Distanza verticale tra le note
    let arrowTextureUp = SKTexture(imageNamed: "arrow_up")
    let arrowTextureDown = SKTexture(imageNamed: "arrow_down")
    let arrowTextureLeft = SKTexture(imageNamed: "arrow_left")
    let arrowTextureRight = SKTexture(imageNamed: "arrow_right")
    
    let winner = SKLabelNode(fontNamed: "Arial")
    
    override func didMove(to view: SKView) {
        
        addChild(winner)
        
        winner.text = String(score)
        winner.fontSize = 65
        winner.fontColor = SKColor.blue
        winner.position = CGPoint(x: frame.midX, y: frame.midY)
        
        createNotes()
        setupScoreLabel()
    }
    
    override func update(_ currentTime: TimeInterval) {
        winner.text = String(score)
    }
    
    func setupScoreLabel() {
        scoreLabel = SKLabelNode(text: "Score: \(score)") // Inizializza l'etichetta con il punteggio attuale
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height - 50) // Posiziona l'etichetta in alto al centro
        scoreLabel.fontName = "Helvetica" // Imposta il tipo di font desiderato
        scoreLabel.fontSize = 28 // Imposta la dimensione del font
        scoreLabel.fontColor = .white // Imposta il colore del testo
        addChild(scoreLabel) // Aggiungi l'etichetta alla scena
    }

    
    func createNotes() {
        let numberOfColumns = columnSequence.count
        
        for i in 0..<numberOfColumns {
            let column = columnSequence[i]
            let note = Note(color: .white, size: CGSize(width: noteWidth, height: noteHeight))
            let yOffset = size.height / 4 + CGFloat(i) * verticalDistanceBetweenNotes // Altezza basata sull'indice
            let xPosition = CGFloat(column) * (noteWidth + distanceBetweenNotes) + noteWidth / 2 - 240
            note.position = CGPoint(x: xPosition, y: yOffset)
            note.name = "Note"
            note.cutDirection = cutDirections[i] // Associa la direzione di taglio alla nota
            
            // Imposta la texture del cubo per la nota attuale
            note.texture = note.cubeTexture // Usa la texture del cubo
            
            notes.append(note)
            addChild(note)
            
            print(xPosition)
        }
        
        // Imposta le texture delle frecce sulla nota attuale
        setArrowTexturesForNotes()
        
        startNotesMovement(bpm: bpm)
    }
    
    func setArrowTexturesForNotes() {
        for (_, note) in notes.enumerated() {
            switch note.cutDirection {
            case .topToBottom:
                note.texture = arrowTextureDown
            case .bottomToTop:
                note.texture = arrowTextureUp
            case .leftToRight:
                note.texture = arrowTextureLeft
            case .rightToLeft:
                note.texture = arrowTextureRight
            default:
                note.texture = note.cubeTexture // Se non c'è una direzione specifica, ripristina la texture del cubo
            }
        }
    }
    
    func startNotesMovement(bpm: Double) {
        //let noteSpeed: CGFloat = 500 // Modifica questa velocità secondo le tue preferenze
        let noteSpeed: CGFloat = 60 / bpm * 1000
        
        let moveAction = SKAction.moveBy(x: 0, y: -1000, duration: TimeInterval(1000 / noteSpeed)) // Modifica la durata in base alla velocità desiderata
        for note in notes {
            note.run(SKAction.repeatForever(moveAction))
        }
    }

    
    var touchPoints: [CGPoint] = []
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        touchPoints.append(touchLocation)
        
        for note in notes {
            if !note.isCut {
                let noteFrame = note.frame
                
                for i in 0..<touchPoints.count - 1 {
                    let startPoint = touchPoints[i]
                    let endPoint = touchPoints[i + 1]
                    
                    if noteFrame.contains(startPoint) && noteFrame.contains(endPoint) {
                        let touchAngle = atan2(endPoint.y - startPoint.y, endPoint.x - startPoint.x)
                        let noteDirection = direction(for: note.cutDirection)
                        let difference = angleDifference(angle1: touchAngle, angle2: noteDirection)
                        let tolerance: CGFloat = CGFloat.pi / 6 // 30 gradi di tolleranza
                        
                        if difference < tolerance {
                            score += 1
                            scoreLabel.text = "Score: \(score)"
                            print(score)
                            // Aggiungi suono, effetti o altre azioni per indicare il taglio della nota
                            // Aggiorna il punteggio, ecc.
                            
                            
                        } else {
                            score -= 1 // Rimuovi un punto se il taglio non è nella direzione corretta
                            scoreLabel.text = "Score: \(score)"
                            print(score)
                            // Aggiungi altre azioni o effetti per indicare un taglio errato
                        }
                        
                        note.isCut = true
                        note.removeFromParent()
                    }
                }
            }
        }
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchPoints.removeAll()
    }
    
    
    
    
    func direction(for cutDirection: CutDirection) -> CGFloat {
        switch cutDirection {
        case .leftToRight:
            return CGFloat.pi // Direzione da sinistra a destra, corrispondente a 180 gradi o pi radianti
        case .rightToLeft:
            return 0 // Direzione da destra a sinistra, corrispondente a 0 gradi o 0 radianti
        case .topToBottom:
            return -CGFloat.pi / 2 // Direzione dall'alto verso il basso, corrispondente a -90 gradi o -pi/2 radianti
        case .bottomToTop:
            return CGFloat.pi / 2 // Direzione dal basso verso l'alto, corrispondente a 90 gradi o pi/2 radianti
        case .any:
            return 0 // Se non c'è una direzione specifica, si può impostare un valore predefinito (in questo caso, 0)
        }
    }
    
    func angleDifference(angle1: CGFloat, angle2: CGFloat) -> CGFloat {
        let twoPi: CGFloat = 2 * .pi
        var difference = (angle2 - angle1).truncatingRemainder(dividingBy: twoPi)
        if difference <= -CGFloat.pi {
            difference += twoPi
        }
        if difference > CGFloat.pi {
            difference -= twoPi
        }
        return abs(difference)
    }
    
    
}
