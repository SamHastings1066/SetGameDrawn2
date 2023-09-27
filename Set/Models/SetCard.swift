//
//  Card.swift
//  Set
//
//  Created by sam hastings on 14/09/2023.
//

import Foundation
import UIKit

struct SetCard: CustomStringConvertible {
    
    // TODO: remove - this is just for debugging
    var description: String {
        return "\(number) \(color) \(shading) \(shape)"
    }
    
    init(number: Number, color: Color, shading: Shading, shape: Shape) {
        self.number = number
        self.color = color
        self.shading = shading
        self.shape = shape
    }
    
    let number: Number
    let color: Color
    let shading: Shading
    let shape: Shape
    
    
}

extension SetCard: Hashable {
    static func ==(lhs: SetCard, rhs:SetCard) -> Bool {
        return lhs.shading == rhs.shading && lhs.color == rhs.color && lhs.number == rhs.number && lhs.shape == rhs.shape
    }
}

// CaseIterable protol allows use of Number.allCases
enum Number: Int, CaseIterable {
    case one = 1 // otherwise automatically gets a raw value of 0
    case two
    case three
}
enum Shape: String, CaseIterable {
    case shape1
    case shape2
    case shape3
}
enum Shading: String, CaseIterable {
    case outline
    case striped
    case solid
}
enum Color: String, CaseIterable {
    case color1
    case color2
    case color3
}
