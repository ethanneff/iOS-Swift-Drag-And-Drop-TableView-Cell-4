//
//  ReorderTableView.swift
//  DragAndDropTableViewCell4
//
//  Created by Ethan Neff on 2/28/16.
//  Copyright © 2016 Ethan Neff. All rights reserved.
//

// TODO: minor memory leak somewhere

import UIKit

class ReorderTableView: UITableView {
  // MARK: - REORDER
  var reorderGesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer()
  var reorderInitalIndexPath: NSIndexPath?
  var reorderPreviousIndexPath: NSIndexPath?
  var reorderSnapshot: UIView = UIView()
  var reorderScrollRate: CGFloat = 0
  var reorderGesturePressed: Bool = false
  var reorderScrollLink: CADisplayLink = CADisplayLink()
  
  
  
  // MARK: - INIT
  override init(frame: CGRect, style: UITableViewStyle) {
    super.init(frame: frame, style: style)
    initHelper()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    initHelper()
  }
  
  convenience init(tableView: UITableView) {
    self.init(frame: CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y, tableView.frame.size.width, tableView.frame.size.height), style: .Plain)
  }
  
  func initHelper() {
    reorderGesture = UILongPressGestureRecognizer(target: self, action: "reorderGestureRecognized:")
    reorderGesture.minimumPressDuration = 0.3
    addGestureRecognizer(reorderGesture)
    
    registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
  }
  
  
  
  // MARK: - GESTURE
  func reorderGestureRecognized(gesture: UILongPressGestureRecognizer) {
    // long press on cell
    let location = gesture.locationInView(self)
    
    switch gesture.state {
    case UIGestureRecognizerState.Began:
      reorderGestureBegan(location: location)
    case UIGestureRecognizerState.Changed:
      reorderGestureChanged(location: location)
    default:
      reorderGestureEnded(location: location)
    }
  }
  
  func reorderGestureBegan(location location: CGPoint) {
    // start looping for scrolling (because want to scroll when non-moving near edges [UIGestureRecognizerState.Change won't be called])
    reorderGesturePressed = true
    reorderScrollLink = CADisplayLink(target: self, selector: "reorderScrollTableWithCell")
    reorderScrollLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
    
    // alert the controller
    if let found = super.delegate?.respondsToSelector("reorderBefore:") where found {
      super.delegate?.performSelector("reorderBefore:", withObject:  indexPathForRowAtPoint(location))
    }
    
    // if the controller changes the initial index
    if let passedInitialIndex = reorderInitalIndexPath {
      // update index if out of bounds
      let section = passedInitialIndex.section
      let touchIndexPath = indexPathForRowAtPoint(location) ?? NSIndexPath(forRow: numberOfRowsInSection(section)-1, inSection: section)
      
      if let cell = cellForRowAtIndexPath(passedInitialIndex) {
        
        // save initial and previous indexes
        reorderInitalIndexPath = reorderInitalIndexPath ?? touchIndexPath
        reorderPreviousIndexPath = touchIndexPath
        
        // reorder
        moveRowAtIndexPath(passedInitialIndex, toIndexPath: touchIndexPath)
        
        
        // create snapshot cell (the pickup cell)
        var center = cell.center
        reorderSnapshot = reorderCreateCellSnapshot(cell)
        reorderSnapshot.center = center
        reorderSnapshot.alpha = 0.0
        addSubview(reorderSnapshot)
        // animate the snapshot rise
        UIView.animateWithDuration(0.35, animations: {
          center.y = location.y
          self.reorderSnapshot.center = center
          self.reorderSnapshot.transform = CGAffineTransformMakeScale(1.05, 1.05)
          self.reorderSnapshot.alpha = 0.8
          
          // hide the below cell (it will be there the entire time)
          cell.alpha = 0.0
          }, completion: { (finished) -> Void in
            if finished {
              cell.hidden = true
            }
        })
      }
      
      
    } else {
      reorderPickUpCell(location: location)
    }
  }
  
  func reorderPickUpCell(location location: CGPoint) {
    if let touchIndexPath = indexPathForRowAtPoint(location) {
      
      // save initial and previous indexes
      reorderInitalIndexPath = touchIndexPath
      reorderPreviousIndexPath = touchIndexPath

      // make cell snapshot (pickup cell)
      if let cell = cellForRowAtIndexPath(reorderInitalIndexPath!) {
        var center = cell.center
        reorderSnapshot = reorderCreateCellSnapshot(cell)
        reorderSnapshot.center = center
        reorderSnapshot.alpha = 0.0
        addSubview(reorderSnapshot)
        
        UIView.animateWithDuration(0.35, animations: {
          // animate the snapshot rise
          center.y = location.y
          self.reorderSnapshot.center = center
          self.reorderSnapshot.transform = CGAffineTransformMakeScale(1.05, 1.05)
          self.reorderSnapshot.alpha = 0.8
          
          // hide the below cell (it will be there the entire time)
          cell.alpha = 0.0
          }, completion: { (finished) -> Void in
            if finished {
              cell.hidden = true
            }
        })
      }
    }
  }
  
  
  func reorderGestureChanged(location location: CGPoint) {
    // move cell
    
    // update position of the drag view so it wont go past the top or the bottom too far
    if location.y >= 0 && location.y <= contentSize.height + 50 {
      reorderSnapshot.center = CGPointMake(center.x, location.y)
    }
    
    // adjust rect for content inset as we will use it below for calculating scroll zones
    var rect: CGRect = bounds
    rect.size.height -= contentInset.top
    
    // use scrollLink loop to move tableView and snapshot by changing the reorderScrollRate property
    let scrollZoneHeight: CGFloat = rect.size.height / 6
    let bottomScrollBeginning: CGFloat = contentOffset.y + contentInset.top + rect.size.height - scrollZoneHeight
    let topScrollBeginning: CGFloat = contentOffset.y + contentInset.top + scrollZoneHeight
    if location.y >= bottomScrollBeginning {
      // bottom
      reorderScrollRate = (location.y - bottomScrollBeginning) / scrollZoneHeight
    } else if location.y <= topScrollBeginning {
      // top
      reorderScrollRate = (location.y - topScrollBeginning) / scrollZoneHeight
    } else {
      // middle
      reorderScrollRate = 0
    }
  }
  
  func reorderGestureEnded(location location: CGPoint) {
    // place cell down
    if let index = reorderPreviousIndexPath, let cell = cellForRowAtIndexPath(index) {
      reorderGesturePressed = false
      cell.hidden = false
      cell.alpha = 0.0
      UIView.animateWithDuration(0.35, animations: {
        self.reorderSnapshot.center = cell.center
        self.reorderSnapshot.transform = CGAffineTransformIdentity
        self.reorderSnapshot.alpha = 0.0
        cell.alpha = 1.0
        }, completion: { (finished) -> Void in
          if finished {
            // alert the controller
            if let found = super.delegate?.respondsToSelector("reorderAfter:toIndex:") where found {
              super.delegate?.performSelector("reorderAfter:toIndex:", withObject: self.reorderInitalIndexPath, withObject: self.reorderPreviousIndexPath)
            }
            
            // clear memory
            cell.hidden = false
            self.reorderScrollRate = 0
            self.reorderScrollLink.invalidate()
            self.reorderInitalIndexPath = nil
            self.reorderPreviousIndexPath = nil
            self.reorderSnapshot.removeFromSuperview()
          }
      })
    }
  }
  
  
  
  // MARK: - SNAPSHOT
  func reorderCreateCellSnapshot(inputView: UIView) -> UIView {
    // the pick up cell (view properties)
    UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
    inputView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
    let image = UIGraphicsGetImageFromCurrentImageContext() as UIImage
    UIGraphicsEndImageContext()
    let cellSnapshot : UIView = UIImageView(image: image)
    cellSnapshot.layer.masksToBounds = false
    cellSnapshot.layer.cornerRadius = 0.0
    cellSnapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0)
    cellSnapshot.layer.shadowRadius = 3.0
    cellSnapshot.layer.shadowOpacity = 0.4
    return cellSnapshot
  }
  
  
  
  // MARK: - SCROLL
  func reorderScrollTableWithCell() {
    // properties
    let gesture: UILongPressGestureRecognizer = reorderGesture
    let location: CGPoint = gesture.locationInView(self)
    let currentOffset: CGPoint = contentOffset
    var newOffset: CGPoint = CGPointMake(currentOffset.x, currentOffset.y + reorderScrollRate * 10)
    
    // scroll the tableview
    if newOffset.y < -contentInset.top {
      newOffset.y = -contentInset.top
    }
    else if contentSize.height + contentInset.bottom < frame.size.height {
      newOffset = currentOffset
    }
    else if newOffset.y > (contentSize.height + contentInset.bottom) - frame.size.height {
      newOffset.y = (contentSize.height + contentInset.bottom) - frame.size.height
    }
    contentOffset = newOffset
    
    // scroll the snapshot
    if location.y >= 0 && location.y <= contentSize.height + 50 {
      reorderSnapshot.center = CGPointMake(center.x, location.y)
    }
    
    // reorder the tableview items
    if reorderGesturePressed {
      reorderUpdateCurrentLocation()
    }
  }
  
  
  
  // MARK: - REORDER
  func reorderUpdateCurrentLocation() {
    let gesture: UILongPressGestureRecognizer = reorderGesture
    let location: CGPoint = gesture.locationInView(self)
    if let touchIndexPath = indexPathForRowAtPoint(location),
      let previousIndexPath = reorderPreviousIndexPath {
        if touchIndexPath != previousIndexPath {
          // reorder the tableview cells
          moveRowAtIndexPath(previousIndexPath, toIndexPath: touchIndexPath)
          reorderPreviousIndexPath = touchIndexPath
        }
    }
  }
}
