# iOS-Swift-Drag-And-Drop-TableView-Cell-4

**purpose** better user experience for reordering a list.

**vision** able to reorder table view cells based on drag and drop gesture.

**methodology** coded in Swift, recycled code from the Objective-C libraries of [HPReorderTableView](https://github.com/hpique/HPReorderTableView) and [BVReorderTableView](https://github.com/bvogelzang/BVReorderTableView) to make a solution which works if the tableview data needs to be modified before and after a user reorders the list. Add optional functions  ```func reorderBefore(index: NSIndexPath) {}``` and ```func reorderAfter(fromIndex: NSIndexPath, toIndex:NSIndexPath) {}``` to listen for changes of the index path.

**status** working.

**eventually** delegate the UITableViewController.reorderBefore and UITableViewController.reorderAfter so the ReorderTableView() does not need both selectors and ReorderTableView.reorderInitialIndexPath to pass data back and forth.

![image](http://i.imgur.com/X5HuY9g.gif)
