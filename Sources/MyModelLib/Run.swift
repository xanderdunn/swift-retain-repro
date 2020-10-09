import Foundation

import RetainTroubleshooting

public func run() {
    print("Running model...")
    let data = MyData()

    while let input = readLine() {
        if input == "stop" {
            break
        } else {
            print("unrecognized input command `\(input)`, accepted commands: stop")
        }
    }
   print("Done.")
}
