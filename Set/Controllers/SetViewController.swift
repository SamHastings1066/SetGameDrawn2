//
//  ViewController.swift
//  Set
//
//  Created by sam hastings on 14/09/2023.
//


// TODO: Preserve the order of the cards in SetGame after they have been replaced with new cards.

import UIKit

class SetViewController: UIViewController {

    private var portraitConstraints: [NSLayoutConstraint] = []
    private var landscapeConstraints: [NSLayoutConstraint] = []
    private var layoutChanged = false
    
    private var setGame = SetGame()
    private var selectedCardViews = [CardView]()
    private let cardsInPlayView = CardsInPlayView()
    private var grid: Grid!
    
    lazy var animator = UIDynamicAnimator(referenceView: view)
    lazy var cardBehaviour = SetCardBehaviour(in: animator)
    
    private let dealMoreCardsButton: UIButton = {
        let button = UIButton(configuration: .filled())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .orange
        button.setTitle("Deal", for: .normal)
        return button
    }()
    
    private let newGameButton: UIButton = {
        let button = UIButton(configuration: .borderless())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .black
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
        super.viewDidLayoutSubviews()
        
        view.layoutIfNeeded()
        // Convert dealMoreCardsButton.frame.origin from view's coordinates to the cardsInPlayView's coordinates
        let translatedDealingDeckOrigin = dealMoreCardsButton.convert(dealMoreCardsButton.frame.origin,
                                                to: cardsInPlayView)
        let translatedDealingDeckFrame = CGRect(origin: translatedDealingDeckOrigin,
                                         size: dealMoreCardsButton.frame.size)
        cardsInPlayView.dealingDeckFrame = translatedDealingDeckFrame
        let translatedMatchedDeckOrigin = dealMoreCardsButton.convert(newGameButton.frame.origin,
                                                to: cardsInPlayView)
        let translatedMatchedDeckFrame = CGRect(origin: translatedMatchedDeckOrigin,
                                         size: dealMoreCardsButton.frame.size)
        cardsInPlayView.matchedDeckFrame = translatedMatchedDeckFrame
        grid = Grid(layout: .aspectRatio(CGFloat(0.625)), frame: CGRect(origin: cardsInPlayView.bounds.origin, size: cardsInPlayView.bounds.size))


        updateCardsInPlayViewFromModel()

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
        
        layoutChanged = true

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
    
    // TODO: move to CardsInPlayView
    func insertCardViewIntoCardsInPlayCardViews(withCard card: SetCard, at index: Int) {
        let cardView = CardView()
        cardView.card = card
        let tap = UITapGestureRecognizer(target: self, action: #selector(cardTapped(_:)))
        cardView.addGestureRecognizer(tap)
        //cardsInPlayView.cardsInPlayCardViews.append(cardView)
        cardsInPlayView.cardsInPlayCardViews.insert(cardView, at: index)
        cardsInPlayView.addSubview(cardView)
    }
    
    func updateCardsInPlayViewFromModel() {
        
        // Update the state of all cardviews in cardsInPlayView.cardsInPlayCardViews
        for cardView in cardsInPlayView.cardsInPlayCardViews {
            if setGame.matchedCards.contains(cardView.card) {
                cardView.state = .matched
            } else if setGame.misMatchedCards.contains(cardView.card) {
                cardView.state = .mismatched
            } else if setGame.selectedCards.contains(cardView.card) {
                cardView.state = .selected
            } else {
                cardView.state = .unselected
            }
        }
        
        // TODO: change these into a function in cardsInPlayView that updates the cardView collections based on the cardview states.
        // Identify any matched cardViews and remove them from cardsInPlayCardViews
        let matchedCardViews = cardsInPlayView.cardsInPlayCardViews.filter({ setGame.matchedCards.contains($0.card) })
        cardsInPlayView.cardsInPlayCardViews.removeAll(where: {!setGame.cardsInPlay.contains($0.card)})
        cardsInPlayView.matchedCardViews += matchedCardViews
        
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 1.0,
            delay: 0.0,
            animations: {
                for cardView in matchedCardViews {
                    self.cardBehaviour.addItem(cardView)
                    cardView.layer.zPosition = CGFloat(Float.greatestFiniteMagnitude)
                }
            },
            completion: {position in
                UIViewPropertyAnimator.runningPropertyAnimator(
                    withDuration:0.6,
                    delay: 0.0,
                    animations: {
                        for cardView in matchedCardViews {
                            self.cardBehaviour.removeItem(cardView)
                            cardView.transform = CGAffineTransform.identity
                            cardView.frame = self.cardsInPlayView.matchedDeckFrame
                        }
                    },
                    completion: { _ in
                        for cardView in matchedCardViews {
                            // Then flip the card
                            UIView.transition(
                                with: cardView,
                                duration: 0.6,
                                options: .transitionFlipFromLeft,
                                animations: {
                                    cardView.isFaceUp = false
                                }
                            )
                        }
                    }
                )
                
            }
        )

        // For any card in setGame.cardsInPlay that isn't already included in cardsInPlay.cardsInPlayCardViews, add a new CardView
        for (index, card) in setGame.cardsInPlay.enumerated() {
            if cardsInPlayView.cardsInPlayCardViews.first(where: {$0.card == card}) == nil {
                insertCardViewIntoCardsInPlayCardViews(withCard: card, at: index)
            }
        }
                
        cardsInPlayView.updateCardViewGrid()
        cardsInPlayView.animateDealingAllCards()
        if layoutChanged {
            cardsInPlayView.updateMatchedCardviewFrames()
            layoutChanged = false
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
    
    // This function should update the setGame and then call updateViewFromModel
    @objc func cardTapped(_ sender: UITapGestureRecognizer? = nil) {
        if let tappedCard = (sender?.view as? CardView)?.card {
            setGame.handleTap(on: tappedCard)
        }

        updateCardsInPlayViewFromModel()
        
        scoreLabel.text = "Score: \(setGame.score)"
        
        
    }
    
    // This function should update the setGame and then call updateViewFromModel
    @objc func dealThreeMoreCards() {
        
        let numCards = 3
        setGame.dealCards(numCards: numCards)
        if setGame.deck.count < 3 {
            disableDealCardsButton()
        }
        updateCardsInPlayViewFromModel()
    }
    
    // This function should update the setGame and then call updateViewFromModel
    @objc func newGame() {
        setGame.resetGame()
        enableDealCardsButton()
        // TODO: delete comments below
//        // this line should be removed and placed in updateViewFromModel function
//        for view in cardsInPlayView.subviews {
//            view.removeFromSuperview()
//        }
//        // this line should be removed and placed in updateViewFromModel function
//        cardsInPlayView.setCardViews = [CardView]()
        //loadCardsInPlayViewFromModel()
        // Empty all CardViews collections
        //        cardsInPlayView.deckCardViews = [CardView]()
        for view in cardsInPlayView.subviews {
            view.removeFromSuperview()
        }
        cardsInPlayView.cardsInPlayCardViews = [CardView]()
        cardsInPlayView.matchedCardViews = [CardView]()
        updateCardsInPlayViewFromModel()
        scoreLabel.text = "Score: \(setGame.score)"
    }
    
    @objc func reshuffleCardsInPlay(recognizer: UIRotationGestureRecognizer) {
        switch recognizer.state {
        case .began:
            for view in cardsInPlayView.subviews {
                view.removeFromSuperview()
            }
            cardsInPlayView.cardsInPlayCardViews = [CardView]()
            setGame.reshuffle()
            updateCardsInPlayViewFromModel()
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
