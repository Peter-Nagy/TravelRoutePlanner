# TravelRoutePlanner

[![Build Status](https://travis-ci.com/Peter-Nagy/TravelRoutePlanner.svg?branch=master)](https://travis-ci.com/Peter-Nagy/TravelRoutePlanner)

This package calculates the most efficient route destinations. 

## Usage

### Adding destinations

```swift
planner.add(destination: "A")
```

### Adding rules for destinations
```swift
planner.add(destination: "B", after: "A")
```

This rule means that destination `B` will always appear after `A`.

### Calculating the route
```swift
try planner.calculateRoute()
```

Returns the most efficient route between the previously added destinations.

Return value: __[String]__, an ordered list of the previously given destinations.

## Running tests
```sh
swift test --enable-test-discovery
```

## Linting
```sh
swiftlint
```

