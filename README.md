# RollCall
A lightweight audit for unbounded memory growth in swift.

Detecting and debugging memory issues (retain cycles, orphaned objects, etc) can be cumbersome.
Instruments is a powerful tool, but can be be overwhelming for both you and your machine.

RollCall tracks the creation of objects and reports which ones are still in memory.

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
