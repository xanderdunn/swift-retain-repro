import Foundation

import NIO

class MyData {
    let eventLoopGroup: EventLoopGroup
    let safeEventLoop: EventLoop
    var dataFeeders: [DataFeeder] = []
    var dataFeeds: [DataFeeder: DataStream] = [:]
    var receivedData: [DataFeeder: BoundedLIFOLinkedList<DataPoint>] = [:]

    init() {
        self.eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount * 2)
        self.safeEventLoop = self.eventLoopGroup.next()
        self.getDataFeeds()
    }

    /**
    Synchronously get the data feeders and store them
    */
    private func getDataFeeds() {
        for i in 0...400 {
            self.dataFeeders.append(DataFeeder(name: "asdf\(i)"))
        }
        self.addNewDataFeeders(dataFeeders: self.dataFeeders)
    }

    func dataCallback(dataFeeder: DataFeeder) -> (([DataPoint]) -> Void) {
        return { dataUpdates in
            let dataFeederLinkedList = self.receivedData[dataFeeder]!
            #if DEBUG
            // The below code block s a debug check to see how often the lack of
            //  FIFO guarantee on async dispatch queues causes old data to be inserted after new data
            // Note: There are no async disaptch queues in this minimal repro code base
            if dataFeederLinkedList.count > 0 && dataUpdates.count > 0 {
                for dataUpdate in dataUpdates {
                    let topDataUpdate = dataFeederLinkedList.suffix(1)![0]
                    // !! errorText - THIS VARIABLE IS THE SOURCE OF THE RETAIN ACCRETION
                    let errorText = """
                    Expected FIFO execution of async dispatch queues, but found historical data being inserted onto \
                    linked list. Top of linked list has time \(dataUpdate.time) \
                    (\(dataUpdate.timeDouble)), \
                    while inserted data with time \(topDataUpdate.time) (\(topDataUpdate.timeDouble))
                    """
                    if topDataUpdate.time > dataUpdate.time {
                        print(errorText)
                        assertionFailure(errorText)
                    }
                }
            }
            #endif
            dataFeederLinkedList.append(contentsOf: dataUpdates)
        }
    }

    func addNewDataFeeders(dataFeeders: [DataFeeder]) {
        for dataFeeder in dataFeeders {
            let dataQueue = BoundedLIFOLinkedList<DataPoint>(sizeLimit: 250)
            self.receivedData[dataFeeder] = dataQueue
            let dataStream = DataStream(dataFeeder: dataFeeder,
                                        eventLoopGroup: self.eventLoopGroup,
                                        dataCallback: self.dataCallback(dataFeeder: dataFeeder))
            self.dataFeeds[dataFeeder] = dataStream
        }
    }
}
