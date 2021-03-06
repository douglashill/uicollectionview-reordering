//
//  ThirdViewController.swift
//  Example
//
//  Created by Wojtek on 14/07/2015.
//  Copyright © 2015 NSHint. All rights reserved.
//

import UIKit

class ThirdViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    private var numbers: [Int] = []
    
    private var selectedIndexPath: NSIndexPath?
    private var panGesture: UIPanGestureRecognizer!
    private var longPressGesture: UILongPressGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for _ in 0...100 {
            let height = Int(arc4random_uniform((UInt32(100)))) + 40
            numbers.append(height)
        }
        
        panGesture = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
        self.collectionView.addGestureRecognizer(panGesture)
        panGesture.delegate = self
        
        longPressGesture = UILongPressGestureRecognizer(target: self, action: "handleLongGesture:")
        self.collectionView.addGestureRecognizer(longPressGesture)
        longPressGesture.delegate = self
    }
    
    func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        
        switch(gesture.state) {
        case UIGestureRecognizerState.Began:
            selectedIndexPath = self.collectionView.indexPathForItemAtPoint(gesture.locationInView(self.collectionView))
        case UIGestureRecognizerState.Changed:
            break
        default:
            selectedIndexPath = nil
        }
    }
    
    func handlePanGesture(gesture: UIPanGestureRecognizer) {
        
        switch(gesture.state) {
            
        case UIGestureRecognizerState.Began:
            collectionView.beginInteractiveMovementForItemAtIndexPath(selectedIndexPath!)
        case UIGestureRecognizerState.Changed:
            collectionView.updateInteractiveMovementTargetPosition(gesture.locationInView(gesture.view!))
        case UIGestureRecognizerState.Ended:
            collectionView.endInteractiveMovement()
        default:
            collectionView.cancelInteractiveMovement()
        }
    }
    
}

extension ThirdViewController: CHTCollectionViewDelegateWaterfallLayout {
    
    func collectionView (collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: Int((view.bounds.width - 40)/3), height: numbers[indexPath.item])
    }
}

extension ThirdViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if gestureRecognizer == longPressGesture {
            return panGesture == otherGestureRecognizer
        }
        
        if gestureRecognizer == panGesture {
            return longPressGesture == otherGestureRecognizer
        }
        
        return true
    }
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        guard gestureRecognizer == self.panGesture else {
            return true
        }
        
        return selectedIndexPath != nil
    }
}

extension ThirdViewController: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numbers.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! TextCollectionViewCell
        cell.textLabel.text = "\(numbers[indexPath.item])"
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, canMoveItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func collectionView(collectionView: UICollectionView, moveItemAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        
        let temp = numbers[sourceIndexPath.item]
        numbers[sourceIndexPath.item] = numbers[destinationIndexPath.item]
        numbers[destinationIndexPath.item] = temp
    }
    
}

//MARK: one little trick
extension CHTCollectionViewWaterfallLayout {
    
    internal override func invalidationContextForInteractivelyMovingItems(targetIndexPaths: [NSIndexPath], withTargetPosition targetPosition: CGPoint, previousIndexPaths: [NSIndexPath], previousPosition: CGPoint) -> UICollectionViewLayoutInvalidationContext {
        
        let context = super.invalidationContextForInteractivelyMovingItems(targetIndexPaths, withTargetPosition: targetPosition, previousIndexPaths: previousIndexPaths, previousPosition: previousPosition)
        
        self.delegate?.collectionView!(self.collectionView!, moveItemAtIndexPath: previousIndexPaths[0], toIndexPath: targetIndexPaths[0])
        
        return context
    }
}
