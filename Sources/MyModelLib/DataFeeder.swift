import Foundation

struct DataFeeder: CustomStringConvertible & Hashable & Equatable {
    let name: String

    init(name: String) {
        self.name = name
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.name)
    }

    static func == (lhs: DataFeeder, rhs: DataFeeder) -> Bool {
        return lhs.name == rhs.name
    }

    static func < (lhs: DataFeeder, rhs: DataFeeder) -> Bool {
        return lhs.name < rhs.name
    }

    var description: String {
        return "\(self.name)"
    }
}
