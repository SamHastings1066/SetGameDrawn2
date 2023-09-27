//
//  CardView.swift
//  Set
//
//  Created by sam hastings on 14/09/2023.
//

import UIKit

class CardView: UIView {
    var shapeColor = UIColor.green
    var card: SetCard!
    private var grid: Grid!
    
    override func draw(_ rect: CGRect) {
        
        grid = Grid(layout: .dimensions(rowCount: card.number.rawValue, columnCount: 1), frame: CGRect(origin: self.bounds.origin, size: self.bounds.size)) // grid used inside a card to layout symbols
        let roundedRect = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        // Make the roundedRect the current clipping path i.e. everything is draw within it's frame
        roundedRect.addClip()
        //set background to white if it's not explicity set externally
        (self.backgroundColor ?? UIColor.white).setFill()
        roundedRect.fill()
        
        switch card.color {
        case .color1:
            shapeColor = UIColor.green
        case .color2:
            shapeColor = UIColor.purple
        case .color3:
            shapeColor = UIColor.orange
        }
        
        for gridIndex in 0..<card.number.rawValue {
            switch card.shape {
            case .shape1:
                drawDiamond(in: grid[gridIndex]!, color: shapeColor)
            case .shape2:
                drawOval(in: grid[gridIndex]!, color: shapeColor)
            case .shape3:
                drawSquiggle(in: grid[gridIndex]!, color: shapeColor)
            }
        }

    }
    
    func drawDiamond(in rect: CGRect, color: UIColor) {
        let diamondHeight = rect.width * 0.32
        let diamondWidth = rect.width * 0.7
        
        let topPoint = CGPoint(x: rect.midX, y: rect.midY - diamondHeight / 2)
        let rightPoint = CGPoint(x: rect.midX + diamondWidth / 2, y: rect.midY)
        let bottomPoint = CGPoint(x: rect.midX, y: rect.midY + diamondHeight / 2)
        let lefttPoint = CGPoint(x: rect.midX - diamondWidth / 2, y: rect.midY)
        
        let diamond = UIBezierPath()
        diamond.move(to: topPoint)
        diamond.addLine(to: rightPoint)
        diamond.addLine(to: bottomPoint)
        diamond.addLine(to: lefttPoint)
        diamond.close()
        diamond.lineWidth = rect.size.width / 90
        color.setStroke()
        diamond.stroke()
        if card.shading == .solid {
            color.setFill()
            diamond.fill()
        } else if card.shading == .striped {
            drawStripes(in: rect, path: diamond)
        }
        
    }
    
    
    func drawOval(in rect: CGRect, color: UIColor) {
        let ovalHeight = rect.width * 0.32
        let ovalWidth = rect.width * 0.7
        
        let topLeftPoint = CGPoint(x: rect.midX - (ovalWidth / 2) + (ovalHeight / 2), y: rect.midY - ovalHeight / 2)
        let rightArcCenter = CGPoint(x: rect.midX - (ovalHeight / 2) + (ovalWidth / 2), y: rect.midY)
        let leftArcCenter = CGPoint(x: rect.midX + (ovalHeight / 2) - (ovalWidth / 2), y: rect.midY)
        
        let oval = UIBezierPath()
        oval.move(to: topLeftPoint)
        oval.addArc(withCenter: rightArcCenter, radius: ovalHeight / 2, startAngle: CGFloat.pi * 1.5, endAngle: CGFloat.pi * 0.5, clockwise: true)
        oval.addArc(withCenter: leftArcCenter, radius: ovalHeight / 2, startAngle: CGFloat.pi * 0.5, endAngle: CGFloat.pi * 1.5, clockwise: true)
        oval.close()
        oval.lineWidth = rect.size.width / 90
        color.setStroke()
        oval.stroke()
        
        if card.shading == .solid {
            color.setFill()
            oval.fill()
        } else if card.shading == .striped {
            drawStripes(in: rect, path: oval)
        }
    }
    
    func drawSquiggle(in rect: CGRect, color: UIColor) {
        let startPoint = CGPoint(x: 76.5, y: 403.5)
        let curves = [ // to, cp1, cp2
            (CGPoint(x:  199.5, y: 295.5), CGPoint(x: 92.463, y: 380.439),
                                           CGPoint(x: 130.171, y: 327.357)),
            (CGPoint(x:  815.5, y: 351.5), CGPoint(x: 418.604, y: 194.822),
                                           CGPoint(x: 631.633, y: 454.052)),
            (CGPoint(x: 1010.5, y: 248.5), CGPoint(x: 844.515, y: 313.007),
                                           CGPoint(x: 937.865, y: 229.987)),
            (CGPoint(x: 1057.5, y: 276.5), CGPoint(x: 1035.564, y: 254.888),
                                           CGPoint(x: 1051.46, y: 270.444)),
            (CGPoint(x:  993.5, y: 665.5), CGPoint(x: 1134.423, y: 353.627),
                                           CGPoint(x: 1105.444, y: 556.041)),
            (CGPoint(x:  860.5, y: 742.5), CGPoint(x: 983.56, y: 675.219),
                                           CGPoint(x: 941.404, y: 715.067)),
            (CGPoint(x:  271.5, y: 728.5), CGPoint(x: 608.267, y: 828.077),
                                           CGPoint(x: 452.192, y: 632.571)),
            (CGPoint(x:  101.5, y: 803.5), CGPoint(x: 207.927, y: 762.251),
                                           CGPoint(x: 156.106, y: 824.214)),
            (CGPoint(x:   49.5, y: 745.5), CGPoint(x: 95.664, y: 801.286),
                                           CGPoint(x: 73.211, y: 791.836)),
            (startPoint, CGPoint(x: 1.465, y: 651.628),
                         CGPoint(x: 1.928, y: 511.233)),
        ]

        // Draw the squiggle
        let squiggle = UIBezierPath()
        squiggle.move(to: startPoint)
        for (to, cp1, cp2) in curves {
            squiggle.addCurve(to: to, controlPoint1: cp1, controlPoint2: cp2)
        }
        squiggle.close()
        // Your code to scale, rotate and translate the squiggle
        let squiggleCenterX = squiggle.bounds.midX
        let squiggleCenterY = squiggle.bounds.midY
        let scaleFactor = 0.7 * (rect.width / squiggle.bounds.width)
        let translateToOrigin = CGAffineTransform(translationX: -squiggleCenterX, y: -squiggleCenterY)
        let translateToCenter = CGAffineTransform(translationX: rect.midX, y: rect.midY)
        let scale = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
        squiggle.apply(translateToOrigin)
        squiggle.apply(scale)
        squiggle.apply(translateToCenter)
        

        squiggle.lineWidth = rect.size.width / 90
        color.setStroke()
        squiggle.stroke()
        if card.shading == .solid {
            color.setFill()
            squiggle.fill()
        } else if card.shading == .striped {
            drawStripes(in: rect, path: squiggle)
        }
        
    }
    

    
    func drawStripes(in rect: CGRect, path: UIBezierPath) {
        if let context = UIGraphicsGetCurrentContext() {
            context.saveGState()
            path.addClip()
            let stripePath = UIBezierPath()
            let stripeWidth = rect.size.width / 90
            for x in stride(from: 0, to: rect.size.width, by: stripeWidth * 3){
                stripePath.move(to: CGPoint(x: rect.origin.x + x, y: rect.origin.y ))
                stripePath.addLine(to: CGPoint(x: rect.origin.x + x, y: rect.origin.y + rect.size.height ))
            }
            stripePath.lineWidth = stripeWidth
            stripePath.stroke()
            context.restoreGState()
        }
    }

}

extension CardView {
    private struct SizeRatio {
        static let cornerRadiusToBoundsHeight: CGFloat = 0.06
    }
    private var cornerRadius: CGFloat {
        return bounds.size.height * SizeRatio.cornerRadiusToBoundsHeight
    }
}



