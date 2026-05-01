import XCTest
@testable import TheBlock

final class VehicleDetailViewModelTests: XCTestCase {
    var bidStore: BidStore!
    var vehicle: Vehicle!
    var viewModel: VehicleDetailViewModel!

    override func setUp() {
        super.setUp()
        bidStore = BidStore()
        vehicle = makeVehicle(currentBid: 10_000, bidCount: 3)
        bidStore.seed(from: [vehicle])
        viewModel = VehicleDetailViewModel(vehicle: vehicle, bidStore: bidStore)
    }

    override func tearDown() {
        viewModel = nil
        vehicle = nil
        bidStore = nil
        super.tearDown()
    }

    private var minimum: Int {
        bidStore.state(for: vehicle.id)?.currentBid ?? vehicle.startingBid
    }

    // MARK: - Valid bid

    func testValidBidSetsDidPlaceBid() {
        viewModel.bidInput = "\(minimum + 500)"
        viewModel.placeBid()
        XCTAssertTrue(viewModel.didPlaceBid)
    }

    func testValidBidClearsError() {
        viewModel.bidInput = "\(minimum + 500)"
        viewModel.placeBid()
        XCTAssertNil(viewModel.bidError)
    }

    func testValidBidClearsInput() {
        viewModel.bidInput = "\(minimum + 500)"
        viewModel.placeBid()
        XCTAssertTrue(viewModel.bidInput.isEmpty)
    }

    func testValidBidUpdatesCurrentBid() {
        let newBid = minimum + 500
        viewModel.bidInput = "\(newBid)"
        viewModel.placeBid()
        XCTAssertEqual(bidStore.state(for: vehicle.id)?.currentBid, newBid)
    }

    func testValidBidIncreasesBidCount() {
        let before = bidStore.state(for: vehicle.id)?.bidCount ?? 0
        viewModel.bidInput = "\(minimum + 500)"
        viewModel.placeBid()
        XCTAssertEqual(bidStore.state(for: vehicle.id)?.bidCount, before + 1)
    }

    func testBidBeforeAuctionStartSetsError() {
        vehicle = makeVehicle(
            currentBid: 10_000,
            bidCount: 3,
            auctionStart: Date(timeIntervalSince1970: 2_000)
        )
        bidStore = BidStore()
        bidStore.seed(from: [vehicle])
        viewModel = VehicleDetailViewModel(
            vehicle: vehicle,
            bidStore: bidStore,
            currentDate: { Date(timeIntervalSince1970: 1_000) }
        )

        viewModel.bidInput = "11000"
        viewModel.placeBid()

        XCTAssertNotNil(viewModel.bidError)
        XCTAssertFalse(viewModel.didPlaceBid)
        XCTAssertEqual(bidStore.state(for: vehicle.id)?.currentBid, 10_000)
        XCTAssertEqual(bidStore.state(for: vehicle.id)?.bidCount, 3)
    }

    // MARK: - Invalid bid

    func testNonNumericInputSetsError() {
        viewModel.bidInput = "abc"
        viewModel.placeBid()
        XCTAssertNotNil(viewModel.bidError)
        XCTAssertFalse(viewModel.didPlaceBid)
    }

    func testBidBelowMinimumSetsError() {
        viewModel.bidInput = "\(minimum - 1)"
        viewModel.placeBid()
        XCTAssertNotNil(viewModel.bidError)
        XCTAssertFalse(viewModel.didPlaceBid)
    }

    func testBidEqualToMinimumSetsError() {
        viewModel.bidInput = "\(minimum)"
        viewModel.placeBid()
        XCTAssertNotNil(viewModel.bidError)
        XCTAssertFalse(viewModel.didPlaceBid)
    }

    // MARK: - Reset

    func testResetBidStatusClearsErrorAndSuccess() {
        viewModel.bidInput = "abc"
        viewModel.placeBid()
        viewModel.resetBidStatus()
        XCTAssertNil(viewModel.bidError)
        XCTAssertFalse(viewModel.didPlaceBid)
    }

    private func makeVehicle(
        currentBid: Int?,
        bidCount: Int,
        auctionStart: Date = Date(timeIntervalSince1970: 0)
    ) -> Vehicle {
        Vehicle(
            id: "vehicle-1",
            vin: "VIN-vehicle-1",
            year: 2021,
            make: "Mazda",
            model: "Mazda3",
            trim: "GT",
            bodyStyle: "Sedan",
            exteriorColor: "Blue",
            interiorColor: "Black",
            engine: "2.0L",
            transmission: "Automatic",
            drivetrain: "FWD",
            odometerKm: 42_000,
            fuelType: "Gasoline",
            conditionGrade: 4.2,
            conditionReport: "Clean",
            damageNotes: [],
            titleStatus: "Clean",
            province: "ON",
            city: "Toronto",
            sellingDealership: "The Block",
            lot: "LOT-vehicle-1",
            auctionStart: auctionStart,
            startingBid: 8_000,
            reservePrice: nil,
            buyNowPrice: nil,
            images: [],
            currentBid: currentBid,
            bidCount: bidCount
        )
    }
}
