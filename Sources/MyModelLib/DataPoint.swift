import Foundation

struct DataPoint: Equatable {
    let size: Double
    let timeDouble: Double
    let time: Date
    let type: String
    let timeUpdateReceived: Date
    let id: String

    init(size: Double,
         timeDouble: Double,
         type: String,
         timeUpdateReceived: Date) {
        self.size = size
        self.timeDouble = timeDouble
        self.time = Date(timeIntervalSince1970: timeDouble)
        self.type = type
        self.timeUpdateReceived = timeUpdateReceived
        let fullString: String = type + "\(size)" + "\(timeDouble)"
        self.id = fullString
    }
}
