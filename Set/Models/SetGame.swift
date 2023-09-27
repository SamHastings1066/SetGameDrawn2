//
//  SetCardDeck.swift
//  Set
//
//  Created by sam hastings on 14/09/2023.
//

import Foundation

struct SetGame {
    private(set) lazy var deck = makeDeck()//[SetCard]()
    var cardsInPlay = [SetCard]()
    //var selectedCards = [Int: SetCard]()
    var selectedCards = [SetCard]()
    var matchedCards = [SetCard]()
    var score = 0
    
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
    
     mutating func replaceSelectedWithNewCards() {
         guard selectedCards.count == 3 else { return }
         
         
         matchedCards.append(contentsOf: selectedCards)
         
         // Deal new cards to cardsInPlay
         for card in selectedCards {
             // check if current selected card is in play
             if let index = cardsInPlay.firstIndex(of: card) {
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
    
    mutating func dealCards(numCards: Int) {
        for _ in 0..<numCards {
            cardsInPlay.append(deck.remove(at: deck.count.arc4random))
        }
    }
    
    mutating func reshuffle() {
        let cardsInPlayCount = cardsInPlay.count
        deck.append(contentsOf: cardsInPlay)
        cardsInPlay.removeAll()
        dealCards(numCards: cardsInPlayCount)
    }
    
    func isSet() -> Bool {
        let uniqueNumbers = Set(selectedCards.map {$0.number})
        let uniqueColors = Set(selectedCards.map {$0.color})
        let uniqueShapes = Set(selectedCards.map {$0.shape})
        let uniqueShadings = Set(selectedCards.map {$0.shading})
        if uniqueColors.count == 2 || uniqueShapes.count == 2 || uniqueNumbers.count == 2 || uniqueShadings.count == 2 {
            return false
        }
        return true
    }
    
    mutating func dealACard() -> SetCard? {
        if !deck.isEmpty {
            return deck.remove(at: deck.count.arc4random)
        }
        return nil
    }
    
    mutating func updateScore() {
        guard selectedCards.count == 3 else {return}
        if isSet() {
            score += 3
        } else {
            score -= 2
        }
    }
    
    mutating func resetGame() {
        deck = makeDeck()
        cardsInPlay = [SetCard]()
//        selectedCards = [Int: SetCard]()
        selectedCards = [SetCard]()
        matchedCards = [SetCard]()
        score = 0
        dealCards(numCards: 12)
    }
}

extension Int {
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

