enum TravelRoutePlannerError: Error {
    case destinationIsAlreadyAdded(String)
    case circularDependency
}

public protocol TravelRoutePlannerProtocol {
    func add(destination: String) throws
    func add(destination: String, after: String) throws
    func calculateRoute() throws -> [String]
}

class TravelRoutePlanner: TravelRoutePlannerProtocol {
    private enum Constants {
        static let rootName = "root"
    }

    private var root = Node(name: Constants.rootName)

    private var visited = Set<String>()

    public func add(destination: String) throws {
        try validateDoesNotExist(name: destination)
        let newDestination = Node(name: destination)
        root.addChild(newDestination)
    }

    public func add(destination: String, after source: String) {
        if let destinationNode = find(name: destination, in: root) {
            let sourceNode = findOrCreate(name: source)
            destinationNode.addChild(sourceNode)
        } else {
            let destinationNode = Node(name: destination)
            let sourceNode = findOrCreate(name: source)
            root.addChild(destinationNode)
            destinationNode.addChild(sourceNode)
            remove(name: source, from: root)
        }
    }

    public func calculateRoute() throws -> [String] {
        visited = []
        return try calculateRoute(root: root).dropLast()
    }

    private func calculateRoute(root current: Node) throws -> [String] {
        try validateHasNotBeenVisitedBefore(name: current.name)
        visited.insert(current.name)
        var destinations = [String]()
        for node in current.children {
            let nodeDestinations = try calculateRoute(root: node)
            destinations.append(contentsOf: nodeDestinations)
        }
        destinations.append(current.name)
        return destinations
    }
}

// Validation
extension TravelRoutePlanner {
    private func validateDoesNotExist(name: String) throws {
        if exists(destination: name) {
            throw TravelRoutePlannerError.destinationIsAlreadyAdded(name)
        }
    }

    private func validateHasNotBeenVisitedBefore(name: String) throws {
        if visited.contains(name) {
            throw TravelRoutePlannerError.circularDependency
        }
    }
}

// Utils
extension TravelRoutePlanner {
    private func remove(name: String, from node: Node) {
        node.children.removeAll { node in node.name == name }
    }

    private func exists(destination: String) -> Bool {
        return find(name: destination, in: root) != nil
    }

    private func findOrCreate(name: String) -> Node {
        if let node = find(name: name, in: root) {
            return node
        }
        return Node(name: name)
    }

    private func find(name: String, in root: Node) -> Node? {
        if root.name == name {
            return root
        }
        for child in root.children {
            if let node = find(name: name, in: child) {
                return node
            }
        }
        return nil
    }
}
