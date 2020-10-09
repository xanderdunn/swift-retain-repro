import Foundation

/// Linked List's Node Class Declaration
public class LinkedListNode<T> {
    var value: T
    var next: LinkedListNode?
    weak var previous: LinkedListNode?

    public init(value: T) {
        self.value = value
    }
}

func lastElementAllToArray<T>(last: LinkedListNode<T>) -> [T] {
    var next: LinkedListNode<T>? = last
    var elements: [T] = []
    while next != nil, let nextNode = next {
        elements.append(nextNode.value)
        next = nextNode.next
    }
    return elements
}

/**
This is a thread-safe, last-in-first-out linked list with a size limit suffix returns the n most recent elements
Thread safety based on:
   https://medium.com/@dmytro.anokhin/concurrency-in-swift-reader-writer-lock-4f255ae73422
This LinkedList implementation was helpful:
   https://github.com/raywenderlich/swift-algorithm-club/tree/master/Linked%20List
If an excessHandler is defined, then when the list reaches its size limit it offloads the entire list to the excessHandler
  and then resets. Otherwise, the size of the list is maintained internally.
*/
class BoundedLIFOLinkedList<T> {
    public typealias Node = LinkedListNode<T>
    typealias S = T

    public let sizeLimit: Int
    internal var _count: Int = 0
    public var head: Node?
    public var last: Node?
    internal let dispatchQueue = DispatchQueue(label: "bounded-queue-thread-safe-queue", attributes: .concurrent)
    internal var handler: ((T) -> Void)?

    public var isEmpty: Bool {
        let result = self.dispatchQueue.sync {
            return self.head == nil
        }
        return result
    }

    public var count: Int {
        let result: Int = self.dispatchQueue.sync {
            return self._count
        }
        return result
    }

    init(sizeLimit: Int, handler: ((T) -> Void)? = nil) {
        self.sizeLimit = sizeLimit
        self.handler = handler
    }

    private func cullExcess() {
        var newLast: Node? = self.last
        while self._count >= self.sizeLimit, let lastNode = self.last {
            newLast = lastNode.next
            self._count -= 1
        }
        self.last = newLast
    }

    public func append(_ value: T) {
        let newNode = Node(value: value)
        self.append(newNode)
    }

    public func append(_ node: Node) {
        self.dispatchQueue.async(flags: .barrier) {
            let newNode = node
            if let headNode = self.head {
                newNode.previous = headNode
                headNode.next = newNode
                self.head = newNode
                self.cullExcess()
            } else {
                self.head = newNode
                self.last = newNode
            }
            if let handler = self.handler {
                handler(node.value)
            }
            self._count += 1
        }
    }

    public func append(contentsOf: [T]) {
        for element in contentsOf {
            let newNode = Node(value: element)
            self.append(newNode)
        }
    }

    /**
    Get the most recent n elements in the LinkedList. 
    Getting elements does not remove them from the list. Calling suffix(n) twice can produce the same or partially
    same elements.
    Note that, unlike Foundaiton's Array.suffix, this call fails if n is larger than total
    number of elements in the linked list,
    */
    public func suffix(_ n: Int) -> [T]? {
        assert(n <= self.count, "Requesting \(n) elements, but the queue only has \(self.count) elements")
        if self.isEmpty {
            print("ERROR: Asking for an element from the queue but it's empty")
            return nil
        } else {
            let result: [T] = self.dispatchQueue.sync {
                var elements: [T] = []
                var nextNode = self.head!
                elements.append(nextNode.value)
                while elements.count < n {
                    if let newNode = nextNode.previous {
                        elements.append(newNode.value)
                        nextNode = newNode
                    } else {
                        let message = "elements.cont: \(elements.count), n: \(n), self.count: \(self.count)"
                        assertionFailure(message)
                    }
                }
                return elements.reversed() // O(1)
            }
            return result
        }
    }

    public func allElements() -> [T] {
        self.dispatchQueue.sync {
            if self._count == 0 {
                return []
            } else {
                return lastElementAllToArray(last: self.last!)
            }
        }
    }

}
