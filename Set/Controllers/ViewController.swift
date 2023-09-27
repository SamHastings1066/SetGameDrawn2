//
//  ViewController.swift
//  Set
//
//  Created by sam hastings on 14/09/2023.
//

//

import UIKit

class ViewController: UIViewController {


    private var setGame = SetGame()
    private var cardView: CardView!
    private var portraitConstraints: [NSLayoutConstraint] = []
    private var landscapeConstraints: [NSLayoutConstraint] = []
    private var scoreUpdated = false // needed to prevent score from being updated twice
    

    
    private let cardsInPlayView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let dealMoreCardsButton: UIButton = {
        let button = UIButton(configuration: .filled())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .orange
        //button.configuration?.background = .clear()
        button.setTitle("Deal more cards", for: .normal)
        return button
    }()
    
    private let newGameButton: UIButton = {
        let button = UIButton(configuration: .filled())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .orange
        button.setTitle("New game", for: .normal)
        return button
    }()

    
    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [dealMoreCardsButton, newGameButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        return stackView
    }()
    
    private let scoreLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()

    
    private var grid: Grid!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemTeal
        dealMoreCardsButton.addTarget(self, action: #selector(dealThreeMoreCards), for: .touchUpInside)
        newGameButton.addTarget(self, action: #selector(newGame), for: .touchUpInside)
        view.addSubview(cardsInPlayView)
        view.addSubview(buttonStackView)
        view.addSubview(scoreLabel)
        setConstraints()
        applyInitialLayoutConstraints()
        addGestureRecognizers()
        setGame.dealCards(numCards: 12)
        scoreLabel.text = "Score: \(setGame.score)"
        
  
    }
    
    override func viewDidLayoutSubviews() {
        grid = Grid(layout: .aspectRatio(CGFloat(0.625)), frame: CGRect(origin: cardsInPlayView.bounds.origin, size: cardsInPlayView.bounds.size))

        drawCards()

    }
    
    
    func addGestureRecognizers() {
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(dealMoreCardsOnSwipe))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
        let rotation = UIRotationGestureRecognizer(target: self, action: #selector(reshuffleCardsInPlay))
        view.addGestureRecognizer(rotation)
    }
    
    func setConstraints() {
        let safeArea = view.safeAreaLayoutGuide

        // cardsInPlayView constraints
        NSLayoutConstraint.activate([
            cardsInPlayView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            cardsInPlayView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            cardsInPlayView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            cardsInPlayView.heightAnchor.constraint(equalTo: safeArea.heightAnchor, multiplier: 0.8)
        ])

        // buttonStackView constraints
        NSLayoutConstraint.activate([
            buttonStackView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            buttonStackView.topAnchor.constraint(equalTo: cardsInPlayView.bottomAnchor, constant: 20),
            buttonStackView.bottomAnchor.constraint(lessThanOrEqualTo: safeArea.bottomAnchor, constant: -5),
        ])
        
        NSLayoutConstraint.activate([
            scoreLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 100)
        ])

        
        // Portrait constraints
        portraitConstraints.append(contentsOf: [
            scoreLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scoreLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])

        // Landscape constraints
        landscapeConstraints.append(contentsOf: [
            scoreLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            scoreLabel.centerYAnchor.constraint(equalTo: buttonStackView.centerYAnchor)
        ])

        // Initially activate portrait constraints
        NSLayoutConstraint.activate(portraitConstraints)

    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        // Check for an orientation change
        if traitCollection.verticalSizeClass != previousTraitCollection?.verticalSizeClass || traitCollection.horizontalSizeClass != previousTraitCollection?.horizontalSizeClass {
            updateLayoutForOrientationChange()
        }
    }

    func updateLayoutForOrientationChange() {
        if traitCollection.verticalSizeClass == .compact { // Landscape
            NSLayoutConstraint.deactivate(portraitConstraints)
            NSLayoutConstraint.activate(landscapeConstraints)
        } else { // Portrait
            NSLayoutConstraint.deactivate(landscapeConstraints)
            NSLayoutConstraint.activate(portraitConstraints)
        }
    }
    
    func applyInitialLayoutConstraints() {
        if traitCollection.verticalSizeClass == .compact { // Landscape
            NSLayoutConstraint.deactivate(portraitConstraints)
            NSLayoutConstraint.activate(landscapeConstraints)
        } else { // Portrait
            NSLayoutConstraint.deactivate(landscapeConstraints)
            NSLayoutConstraint.activate(portraitConstraints)
        }
    }


    
    func drawCards() {
        
        // Clear out any existing cardViews
        for view in cardsInPlayView.subviews {
            view.removeFromSuperview()
        }
        
        grid.cellCount = setGame.cardsInPlay.count
        
        // Print the frame of the cardsInPlayView
        setGame.cardsInPlay.enumerated().forEach { [unowned self] (index, card) in
            guard let cellFrame = grid[index] else { return } // Safely unwrap the optional frame
            let insetAmountX = cellFrame.size.width * 0.03
            let insetAmountY = cellFrame.size.height * 0.02
            let insetCellFrame = cellFrame.insetBy(dx: insetAmountX, dy: insetAmountY)
            cardView = CardView(frame: insetCellFrame)
            cardView.card = card
            cardView.isOpaque = false // to ensure corners are not black
            
            if setGame.selectedCards.contains(card) {
                if setGame.selectedCards.count == 3 {
                    if !scoreUpdated {
                        setGame.updateScore()
                        scoreUpdated = true
                    }
                    if setGame.isSet() {
                        cardView.backgroundColor = UIColor.green.withAlphaComponent(0.2)
                        cardView.layer.borderColor = UIColor.clear.cgColor
                        cardView.layer.borderWidth = 5
                    } else {
                        cardView.backgroundColor = UIColor.red.withAlphaComponent(0.2)
                        cardView.layer.borderColor = UIColor.clear.cgColor
                        cardView.layer.borderWidth = 5
                    }
                } else {
                    scoreUpdated = false
                    cardView.layer.borderColor = UIColor.blue.cgColor
                    cardView.layer.borderWidth = 5
                }
                
                
            }
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(cardTapped(_:)))
            cardView.addGestureRecognizer(tap)
            cardsInPlayView.addSubview(cardView)
        }
        
    }
    
    func disableDealCardsButton() {
        dealMoreCardsButton.isEnabled = false
        dealMoreCardsButton.isHidden = true
    }
    
    func enableDealCardsButton() {
        dealMoreCardsButton.isEnabled = true
        dealMoreCardsButton.isHidden = false
    }
    
    @objc func cardTapped(_ sender: UITapGestureRecognizer? = nil) {
        if let tappedCard = (sender?.view as? CardView)?.card {
            // check if this is the third card selected
            if setGame.selectedCards.count == 3 {
                if setGame.isSet() {
                    setGame.replaceSelectedWithNewCards()
                } else {
                    setGame.selectedCards.removeAll()
                }
            }
            if setGame.selectedCards.contains(tappedCard) {
                setGame.selectedCards.removeAll(where: {$0 == tappedCard})
            } else {
                setGame.selectedCards.append(tappedCard)
            }
        }
        drawCards()
        scoreLabel.text = "Score: \(setGame.score)"
        
    }
    
    @objc func dealThreeMoreCards() {
        let numCards = 3
        setGame.dealCards(numCards: numCards)
        drawCards()
        if setGame.deck.count < 3 {
            disableDealCardsButton()
        }
    }
    
    @objc func newGame() {
        setGame.resetGame()
        enableDealCardsButton()
        scoreLabel.text = "Score: \(setGame.score)"
        drawCards()
    }
    
    @objc func reshuffleCardsInPlay(recognizer: UIRotationGestureRecognizer) {
        switch recognizer.state {
        case .began:
            setGame.reshuffle()
            drawCards()
        default:
            break
        }
    }
    
    @objc func dealMoreCardsOnSwipe(recognizer: UISwipeGestureRecognizer) {
        switch recognizer.direction {
        case .down:
            dealThreeMoreCards()
        default:
            break
        }
    }
    
    
}
