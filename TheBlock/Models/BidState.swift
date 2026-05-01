import Foundation

struct BidState {
    var currentBid: Int
    var bidCount: Int
}

class BidStore: ObservableObject {
    @Published private(set) var bids: [String: BidState] = [:]

    func seed(from vehicles: [Vehicle]) {
        for vehicle in vehicles {
            bids[vehicle.id] = BidState(
                currentBid: vehicle.currentBid,
                bidCount: vehicle.bidCount
            )
        }
    }

    func placeBid(vehicleID: String, amount: Int) {
        guard var state = bids[vehicleID] else { return }
        state.currentBid = amount
        state.bidCount += 1
        bids[vehicleID] = state
    }

    func state(for vehicleID: String) -> BidState? {
        bids[vehicleID]
    }
}
