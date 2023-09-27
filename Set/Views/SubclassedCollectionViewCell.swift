//
//  SubclassedCollectionViewCell.swift
//  Set
//
//  Created by sam hastings on 15/09/2023.
//

import UIKit

class SubclassedCollectionViewCell: UICollectionViewCell {
    
    private let cellLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(cellLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.backgroundColor = .gray
        cellLabel.attributedText = nil
        cellLabel.alpha = 1.0
    }
    
    func setupCell(setCard: SetCard) {
        self.backgroundColor = .gray
        
        var alpha: Double {
            switch setCard.shading {
            case .striped: return 0.25
            default: return 1
            }
        }
        var strokeWidth: Double {
            switch setCard.shading {
            case .outline: return 5.0
            default: return 0
            }
        }
        var color: UIColor {
            switch setCard.color {
            case .color1: return UIColor.systemPink
            case .color2: return UIColor.green
            case .color3: return UIColor.purple
            }
        }
        var shape: String {
            switch setCard.shape {
            case .shape1: return "▲"
            case .shape2: return "●"
            case .shape3: return "■"
            }
        }
        
        cellLabel.alpha = alpha // set for striped
        let attributes: [NSAttributedString.Key : Any] = [
            .strokeWidth : strokeWidth, // set for outline
            .foregroundColor: color,
        ]
        let cellText = String(repeating: shape, count: setCard.number.rawValue)
        cellLabel.attributedText = NSAttributedString(string: cellText, attributes: attributes)
        cellLabel.sizeToFit()
    }
}
