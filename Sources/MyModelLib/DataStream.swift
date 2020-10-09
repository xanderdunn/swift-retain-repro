import Foundation

import NIO

class DataStream {
    let dataFeeder: DataFeeder
    let dataCallback: (([DataPoint]) -> Void)
    let safeEventLoop: EventLoop

    init(dataFeeder: DataFeeder,
         eventLoopGroup: EventLoopGroup,
         dataCallback: @escaping (([DataPoint]) -> Void)) {
        self.dataFeeder = dataFeeder
        self.safeEventLoop = eventLoopGroup.next()
        self.dataCallback = dataCallback
        self.mockedCallback()
    }

    func mockedData() -> [DataPoint] {
        let dataPoint = DataPoint(size: 22.22,
                                  timeDouble: 1234.1234,
                                  type: "test",
                                  timeUpdateReceived: Date())
        let dataPoints = Array(repeating: dataPoint, count: 10000)
        return dataPoints
    }

    func mockedCallback() {
        _ = self.safeEventLoop.scheduleTask(in: .seconds(1)) {
            let dataPoints = self.mockedData()
            self.dataCallback(dataPoints)
            self.mockedCallback()
        }
    }
}
