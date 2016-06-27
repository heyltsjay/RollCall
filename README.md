# RollCall
A lightweight audit for unbounded memory growth in swift.


###Overview
Detecting and debugging memory issues (retain cycles, orphaned objects, etc) can be cumbersome.
Instruments is a powerful tool, but can be be overwhelming for both you and your machine.

Most memory issues will exist classes whose implementation you own. RollCall tracks the creation of objects in your namespace and reports which ones are still in memory.

###High-Level Usage

1. Setup RollCall
2. Use your app for a while
3. Perform a RollCall and check for unexpected objects in memory

# Usage

Somehwere early in your app's lifecycle, initailize with
```
RollCall.setup()
```

Sometime later on, hit a breakpoint and enter into the debugger
```
po NSObject.rollCall()
```

Roll Call will report how many of each object are in memory:
```
(lldb) po NSObject.rollCall()
Roll call:
  MyModelObject 1
  MyListViewController 1
  MyDetailViewController 1
  MyTableViewCell 4
  MyTabViewController 1
  MyNavController 2
```

Roll Call will report subclasses of the calling `Class`
```
(lldb) po UIViewController.rollCall()
Roll call:
  MyListViewController 1
  MyDetailViewController 1
  MyTabViewController 1
  MyNavController 2
  
(lldb) po MyDetailViewController.rollCall()
Roll call:
  MyDetailViewController 1
```
