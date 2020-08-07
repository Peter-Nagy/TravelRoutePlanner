public class Node {
    let name: String
    var children: [Node] = []

    init(name: String) {
        self.name = name
    }

    func addChild(_ node: Node) {
        children.append(node)
    }
}