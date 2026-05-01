import Foundation

class VehicleDetailViewModel: ObservableObject {
    let vehicle: Vehicle

    @Published var bidInput = ""
    @Published private(set) var bidError: String?
    @Published private(set) var didPlaceBid = false

    private let bidStore: BidStore
    private let currentDate: () -> Date

    init(
        vehicle: Vehicle,
        bidStore: BidStore,
        currentDate: @escaping () -> Date = Date.init
    ) {
        self.vehicle = vehicle
        self.bidStore = bidStore
        self.currentDate = currentDate
    }

    var hasAuctionStarted: Bool {
        vehicle.auctionStart <= currentDate()
    }

    func placeBid() {
        didPlaceBid = false

        guard hasAuctionStarted else {
            bidError = "Bidding has not opened yet"
            return
        }

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
