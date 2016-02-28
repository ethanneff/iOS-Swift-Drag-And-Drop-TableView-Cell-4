//
//  TableViewController.swift
//  DragAndDropTableViewCell4
//
//  Created by Ethan Neff on 2/28/16.
//  Copyright © 2016 Ethan Neff. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
  // MARK: - properties
  var items = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25]
  
  
  
  // MARK: - init
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // reorder
    tableView = ReorderTableView(tableView: tableView)
    
    // nav controller properties
    navigationController?.navigationBarHidden = true
    
    // table properties
    tableView.contentInset = UIEdgeInsetsZero
    tableView.separatorInset = UIEdgeInsetsZero
    tableView.scrollIndicatorInsets = UIEdgeInsetsZero
    tableView.layoutMargins = UIEdgeInsetsZero
    tableView.tableFooterView = UIView(frame: CGRectZero)
  }
  
  
  
  // MARK: - reorder functions
  // (optional but needed to reorder your data behind the view)
  func reorderBefore(index: NSIndexPath) {
    // if you update the tableView before the reorder, you need to update the tableView.reorderInitalIndexPath
  }
  
  
  func reorderAfter(fromIndex: NSIndexPath, toIndex:NSIndexPath) {
    // update view data (reorder based on direction moved)
    let ascending = fromIndex.row < toIndex.row ? true : false
    let from = ascending ? fromIndex.row : fromIndex.row+1
    let to = ascending ? toIndex.row+1 : toIndex.row
    
    items.insert(items[fromIndex.row], atIndex: to)
    items.removeAtIndex(from)
    print(items)
  }
  

  
  // MARK: - table view datasource
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
    
    // cell properties
    cell.separatorInset = UIEdgeInsetsZero
    cell.layoutMargins = UIEdgeInsetsZero
    cell.selectionStyle = .None
    cell.textLabel?.text = String(items[indexPath.row])
    
    return cell
  }
}
