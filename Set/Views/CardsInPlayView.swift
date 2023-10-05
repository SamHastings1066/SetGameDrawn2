//
//  CardsInPlayView.swift
//  Set
//
//  Created by sam hastings on 28/09/2023.
//

// TODO: prevent dealing already visible cards when you click deal button
// TODO: flip cards at the end of the animation
// TODO: change the aspect ratio of the cards to horizontal and updte the symbols grid to be the same
// TODO: make this whole thing more object orientated

import UIKit

class CardsInPlayView: UIView {
    
    /// The frame defining the origin and size of the rectangle containing the deck cards are delt from.
    var dealingDeckFrame: CGRect!
    
    /// The frame defining the origin and size of the rectangle containing the deck cards matched cards are sent to.
    var matchedDeckFrame: CGRect!
    
    /// The collection of CardViews for SetCards that have not yet been dealt
    var deckCardViews = [CardView]()
    
    /// The collection of CardViews for SetCards that been dealt to table and are not yet matched.
    var cardsInPlayCardViews = [CardView]()
    //var selectedCardViews = [CardView]() // maybe not necessary.
    
    // TODO: remove if you don't need
    /// The collection of CardViews for SetCards that have been matched and removed from the table.
    var matchedCardViews = [CardView]()
    
    /// The grid used to set the frames for the CardViews in cardsInPlayCardViews
    var grid: Grid!
   
    
    // Boolean showing whether the CardsInPlayView instance is currently performing the dealing animation
    var isAnimatingDealing = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(code:) has not been implemented")
    }
    
    /// Update all matched cardview frames to the matchedDeckFrame
    func updateMatchedCardviewFrames() {
        matchedCardViews.forEach { CardView in
            CardView.frame = matchedDeckFrame
        }
    }
    
    /// Creates a new grid based on the number of cardsInPlayCardViews and sets the frame for each cardView according to that grid.
    func updateCardViewGrid() {
        guard cardsInPlayCardViews.count > 0 else { return }
        // Create a grid from the cards in play
        grid = Grid(layout: .aspectRatio(CGFloat(0.625)), frame: CGRect(origin: self.bounds.origin, size: self.bounds.size))
        grid.cellCount = cardsInPlayCardViews.count
        cardsInPlayCardViews.enumerated().forEach { [unowned self] (index, cardView) in
            guard let cellFrame = grid[index] else { return } // Safely unwrap the optional frame
            let insetAmountX = cellFrame.size.width * 0.03
            let insetAmountY = cellFrame.size.height * 0.02
            let insetCellFrame = cellFrame.insetBy(dx: insetAmountX, dy: insetAmountY)
            cardView.frame = insetCellFrame
        }
    }
    
    func addAllCardViewsAsSubviews() {
        for view in self.subviews {
            view.removeFromSuperview()
        }
        for cardView in cardsInPlayCardViews {
            self.addSubview(cardView)
        }
    }
    
    func animateDealingCard() {
        // guard condition to ensure there is at least one card not yet visible.
        // The animation is therefore only applied to cards that have been dealt but are not yet visible.
        // This is the terminal condition in the recursion
       
        //guard let cardView = setCardViews.first(where: { !$0.isVisible }) else {
        guard let cardView = cardsInPlayCardViews.first(where: { !$0.isVisible }) else {
            isAnimatingDealing = false // All cards have been animated, reset the flag
            return
        }
        // Destination frame
        let destinationFrame = cardView.frame
        cardView.isFaceUp = false
        cardView.frame = dealingDeckFrame
        cardView.isVisible = true
        

        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.2,
            delay: 0,
            options: .curveEaseIn,
            animations: {
                cardView.bounds.size = destinationFrame.size
                cardView.frame = destinationFrame
            }, completion: { _ in
                // Then flip the card
                UIView.transition(
                    with: cardView,
                    duration: 0.6,
                    options: .transitionFlipFromLeft,
                    animations: {
                        cardView.isFaceUp = true
                    }
                )
                // And initiate dealing the next card
                self.animateDealingCard()
            }
        )
        
        
    }
    
    func animateDealingAllCards() {
        guard isAnimatingDealing == false else { return }
        isAnimatingDealing = true // Animation is now commencing
        
        // Start the recursive animation sequence
        animateDealingCard()
    }

}
