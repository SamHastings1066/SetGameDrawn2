//
//  SetCardBehaviour.swift
//  Set
//
//  Created by sam hastings on 01/10/2023.
//

import UIKit

class SetCardBehaviour: UIDynamicBehavior {
    
    // update collision and push behaviour to animate cards flying around bouncing off the walls
    
    lazy var collisionBehaviour: UICollisionBehavior = {
        let behavior = UICollisionBehavior()
        behavior.translatesReferenceBoundsIntoBoundary = true
        return behavior
    }()
    

    
    private func push(_ item: UIDynamicItem) {
        let push = UIPushBehavior(items: [item], mode: .instantaneous)
        
        push.angle = 2 * CGFloat.pi * CGFloat(drand48())
        push.magnitude  = CGFloat(10.0)
        push.action = { [unowned push, weak self] in
            self?.removeChildBehavior(push)
        }
        addChildBehavior(push)
    }
    
    func addItem(_ item: UIDynamicItem) {
        collisionBehaviour.addItem(item)
        push(item)
    }
    
    func removeItem(_ item: UIDynamicItem) {
        collisionBehaviour.removeItem(item)
    }
    
    override init() {
        super.init()
        addChildBehavior(collisionBehaviour)
    }
    
    convenience init(in animator: UIDynamicAnimator) {
        self.init()
        animator.addBehavior(self)
    }
}
