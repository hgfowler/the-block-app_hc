import Foundation

class VehicleDetailViewModel: ObservableObject {
    let vehicle: Vehicle

    @Published var bidInput = ""
    @Published private(set) var bidError: String?
    @Published private(set) var didPlaceBid = false

    private let bidStore: BidStore

    init(vehicle: Vehicle, bidStore: BidStore) {
        self.vehicle = vehicle
        self.bidStore = bidStore
    }

    func placeBid() {
        guard let amount = Int(bidInput) else {
            bidError = "Please enter a valid amount"
            return
        }
        let minimum = bidStore.state(for: vehicle.id)?.currentBid ?? vehicle.currentBid ?? vehicle.startingBid
        guard amount > minimum else {
            bidError = "Bid must exceed $\(minimum.formatted())"
            return
        }
        bidStore.placeBid(vehicleID: vehicle.id, amount: amount)
        bidInput = ""
        bidError = nil
        didPlaceBid = true
    }

    func resetBidStatus() {
        didPlaceBid = false
        bidError = nil
    }
}
