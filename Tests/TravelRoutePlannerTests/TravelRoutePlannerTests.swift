import XCTest
import Nimble
@testable import TravelRoutePlanner

final class TravelRoutePlannerTests: XCTestCase {
    var planner = TravelRoutePlanner()

    func test_whenARouteIsCalculatedWithoutAnyDestinations_thenItShouldReturnEmptyArray() {
        // When
        let route = try? planner.calculateRoute()

        // Then
        expect(route).to(beEmpty())
    }

    func test_whenASingleDestinationIsAdded_thenItShouldReturnThatSingleDestination() {
        // Given
        try? planner.add(destination: "u")

        // When
        let route = try? planner.calculateRoute()

        // Then
        expect(route).to(equal(["u"]))
    }

    func test_whenAddingDestinationsWithoutDependencies_thenItShouldReturnAllDestinationsInAnyOrder() {
        // Given
        try? planner.add(destination: "x")
        try? planner.add(destination: "y")
        try? planner.add(destination: "z")

        // When
        let route = try? planner.calculateRoute()

        // Then
        expect(route).to(contain(["x", "z", "y"]))
    }

    func test_whenAddingASingleDependency_thenItShouldRespectIt() {
        // Given
        try? planner.add(destination: "x")
        try? planner.add(destination: "z")
        planner.add(destination: "y", after: "z")

        // When
        let route = try? planner.calculateRoute()

        // Then
        expect(route).to(have(element: "y", after: "z"))

        expect(route).to(contain(["x", "z", "y"]))
    }

    func test_whenAddingMultipleDependencies_thenItShouldRespectThoseRules() {
        // Given
        try? planner.add(destination: "u")
        try? planner.add(destination: "z")
        planner.add(destination: "x", after: "u")
        planner.add(destination: "w", after: "z")
        planner.add(destination: "v", after: "w")
        planner.add(destination: "y", after: "v")

        // When
        let route = try? planner.calculateRoute()

        // Then
        expect(route).to(have(element: "x", after: "u"))
        expect(route).to(have(element: "w", after: "z"))
        expect(route).to(have(element: "v", after: "w"))
        expect(route).to(have(element: "y", after: "v"))

        expect(route).to(contain(["u", "z", "x", "w", "v", "y"]))
    }

    func test_whenAddingADestinationTwice_thenItThrowsError() {
        // Given
        try? planner.add(destination: "x")
        let expectedError = TravelRoutePlannerError.destinationIsAlreadyAdded("x")

        // When
        expect { try self.planner.add(destination: "x") }.to(throwError(expectedError))
    }

    func test_whenAddingARuleForNonExistentDestinations_thenItShouldCreateThoseDestinations() {
        // Given
        planner.add(destination: "x", after: "y")

        // When
        let route = try? planner.calculateRoute()

        // Then
        expect(route).to(equal(["y", "x"]))
    }

    func test_whenAddingCircularDependencies_thenItShouldThrowError() {
        // Given
        planner.add(destination: "a", after: "b")
        planner.add(destination: "b", after: "c")
        planner.add(destination: "c", after: "a")
        let expectedError = TravelRoutePlannerError.circularDependency

        // When
        expect { try self.planner.calculateRoute() }.to(throwError(expectedError))
    }

    func have(element: String, after: String) -> Predicate<[String]> {
        return Predicate.simple("<\(element)> is after <\(after)>") { actualExpression in
            guard let actual = try actualExpression.evaluate(),
                  let indexOfSecondElement = actual.firstIndex(of: element),
                  let indexOfFirstElement = actual.firstIndex(of: after)
                else { return .fail }
            return PredicateStatus(bool: indexOfFirstElement < indexOfSecondElement)
        }
    }
}
