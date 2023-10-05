//
//  SetCardDeck.swift
//  Set
//
//  Created by sam hastings on 14/09/2023.
//

import Foundation

struct SetGame {
    
    /// The collection of SetCards that have not yet been dealt
    private(set) lazy var deck = makeDeck()
    
    /// The collection of SetCards that been dealt to table and are not yet matched.
    var cardsInPlay = [SetCard]()
    
    /// The subset of cardsInPlay that have been selected by the user
    var selectedCards = [SetCard]()
    
    /// The collection of SetCards that have been matched and removed from the table.
    var matchedCards = [SetCard]()
    
    /// The collection of SetCards that have been mismatched.
    var misMatchedCards = [SetCard]()
    
    /// The user's score.
    var score = 0
    
    /// Returns a deck of SetCards containing all 81 possible combinations of Number, Color, Shading and Shape.
    func makeDeck() -> [SetCard] {
        var outputDeck = [SetCard]()
        for number in Number.allCases {
            for color in Color.allCases{
                for shading in Shading.allCases {
                    for shape in Shape.allCases{
                        outputDeck.append(SetCard(number: number, color: color, shading: shading, shape: shape))
                    }
                }
            }
        }
        return outputDeck
    }
    
    ///
    mutating func handleTap(on tappedCard: SetCard) {
        misMatchedCards = [SetCard]()
        if selectedCards.contains(tappedCard) {
            // deselect card if it is already highlighted
            selectedCards.removeAll(where: {$0 == tappedCard})
        } else {
            // select card
            selectedCards.append(tappedCard)
        }
        if selectedCards.count == 3 {
            updateScore()
            if isSet() {
                matchedCards += selectedCards
                replaceSelectedWithNewCards()
            } else {
                misMatchedCards += selectedCards
            }
            selectedCards.removeAll()
        }

    }
    
    /// Replaces selected cards with new cards from the deck, or else if the deck is empty removes the selected cards without replacement.
    mutating func replaceSelectedWithNewCards() {
        guard selectedCards.count == 3 else { return }
        
        matchedCards.append(contentsOf: selectedCards)
        
        // Deal new cards to cardsInPlay
        for selectedCard in selectedCards {
            // check if current selected card is in play
            if let index = cardsInPlay.firstIndex(of: selectedCard) {
                // if the deck is non empty and you can deal a newCard, replace the selected care with newCard, else remove selected card
                if let newCard = dealACard() {
                    cardsInPlay[index] = newCard
                } else {
                    cardsInPlay.remove(at: index)
                }
            }
        }
        
        // Empty selectedCards
        selectedCards.removeAll()
    }
    
    /// Returns a randomly selected SetCard from the deck, or if the deck is empty returns nil.
    mutating func dealACard() -> SetCard? {
        if !deck.isEmpty {
            return deck.remove(at: deck.count.arc4random)
        }
        return nil
    }
    
    /// Removes 'numCards' number of cards from the deck, at random, and appends them to the cardsInPlay
    mutating func dealCards(numCards: Int) {
        for _ in 0..<numCards {
            if let newCard = dealACard() {
                cardsInPlay.append(newCard)
            }
        }
    }
    
    /// Regenerates cardsInPlay by randomly selecting cards from the combination of cardsInPlay and the deck such that the total count of cardsInPlay remains unchanged.
    mutating func reshuffle() {
        let cardsInPlayCount = cardsInPlay.count
        deck.append(contentsOf: cardsInPlay)
        cardsInPlay.removeAll()
        dealCards(numCards: cardsInPlayCount)
    }
    
    /// Returns true if three cards in selectedCards form a Set, false otherwise
    func isSet() -> Bool {
        guard selectedCards.count == 3 else {return false}
        //return true // for debugging
        let uniqueNumbers = Set(selectedCards.map {$0.number})
        let uniqueColors = Set(selectedCards.map {$0.color})
        let uniqueShapes = Set(selectedCards.map {$0.shape})
        let uniqueShadings = Set(selectedCards.map {$0.shading})
        if uniqueColors.count == 2 || uniqueShapes.count == 2 || uniqueNumbers.count == 2 || uniqueShadings.count == 2 {
            return false
        }
        return true
    }
    
    /// Updates the user's score
    mutating func updateScore() {
        guard selectedCards.count == 3 else {return}
        if isSet() {
            score += 3
        } else {
            score -= 2
        }
    }
    
    /// Resets the SetGame by recreating the deck, and emptying the cardsInPlay, selectedCards, matchedCards, score and dealing 12 new cards.
    mutating func resetGame() {
        deck = makeDeck()
        cardsInPlay = [SetCard]()
        selectedCards = [SetCard]()
        matchedCards = [SetCard]()
        score = 0
        dealCards(numCards: 12)
    }
}

extension Int {
    /// Returns a random Int between 0 and the receiver Int
    var arc4random: Int {
        if self > 0 {
            return Int(arc4random_uniform(UInt32(self)))
        } else if self < 0 {
            return -Int(arc4random_uniform(UInt32(abs(self))))
        } else {
            return 0
        }
    }
}

