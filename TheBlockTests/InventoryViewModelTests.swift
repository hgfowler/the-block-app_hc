import XCTest
@testable import TheBlock

final class InventoryViewModelTests: XCTestCase {
    var bidStore: BidStore!
    var viewModel: InventoryViewModel!

    override func setUp() {
        super.setUp()
        bidStore = BidStore()
        let vehicles = [
            makeVehicle(
                id: "mazda-3",
                year: 2021,
                make: "Mazda",
                model: "Mazda3",
                trim: "GT Turbo",
                bodyStyle: "Sedan",
                odometerKm: 45_000,
                conditionGrade: 4.1,
                city: "Toronto",
                auctionStart: Date(timeIntervalSince1970: 0),
                startingBid: 12_000,
                buyNowPrice: 16_000,
                currentBid: 13_500,
                bidCount: 2
            ),
            makeVehicle(
                id: "ford-f150",
                year: 2019,
                make: "Ford",
                model: "F-150",
                trim: "Lariat",
                bodyStyle: "Truck",
                odometerKm: 85_000,
                conditionGrade: 3.7,
                city: "Calgary",
                auctionStart: Date(timeIntervalSince1970: 2_000),
                startingBid: 20_000,
                buyNowPrice: nil,
                currentBid: nil,
                bidCount: 0
            ),
            makeVehicle(
                id: "honda-civic",
                year: 2023,
                make: "Honda",
                model: "Civic",
                trim: "Touring",
                bodyStyle: "Sedan",
                odometerKm: 18_000,
                conditionGrade: 4.8,
                city: "Vancouver",
                auctionStart: Date(timeIntervalSince1970: 0),
                startingBid: 15_000,
                buyNowPrice: nil,
                currentBid: 18_000,
                bidCount: 4
            )
        ]
        viewModel = InventoryViewModel(
            bidStore: bidStore,
            vehicleLoader: { vehicles }
        )
        viewModel.load()
    }

    override func tearDown() {
        viewModel = nil
        bidStore = nil
        super.tearDown()
    }

    // MARK: - Load

    func testLoadPopulatesVehiclesFromLoader() {
        XCTAssertEqual(viewModel.baseVehicles.map(\.id), ["mazda-3", "ford-f150", "honda-civic"])
    }

    func testLoadClearsError() {
        XCTAssertNil(viewModel.loadError)
    }

    func testLoadSeedsBidStoreWithCurrentOrStartingBid() {
        XCTAssertEqual(bidStore.state(for: "mazda-3")?.currentBid, 13_500)
        XCTAssertEqual(bidStore.state(for: "mazda-3")?.bidCount, 2)
        XCTAssertEqual(bidStore.state(for: "ford-f150")?.currentBid, 20_000)
        XCTAssertEqual(bidStore.state(for: "ford-f150")?.bidCount, 0)
    }

    func testLoadDoesNotOverwriteExistingBids() {
        bidStore.placeBid(vehicleID: "mazda-3", amount: 25_000)

        viewModel.load()

        XCTAssertEqual(bidStore.state(for: "mazda-3")?.currentBid, 25_000)
        XCTAssertEqual(bidStore.state(for: "mazda-3")?.bidCount, 3)
    }

    func testLoadFailureSetsError() {
        viewModel = InventoryViewModel(bidStore: bidStore) {
            throw TestError.loadFailed
        }

        viewModel.load()

        XCTAssertNotNil(viewModel.loadError)
        XCTAssertTrue(viewModel.baseVehicles.isEmpty)
    }

    // MARK: - Search

    func testEmptySearchReturnsAllVehicles() {
        viewModel.searchText = ""
        XCTAssertEqual(viewModel.vehicles.count, viewModel.baseVehicles.count)
    }

    func testSearchFiltersByMake() {
        viewModel.searchText = "mazda"
        XCTAssertEqual(viewModel.vehicles.map(\.id), ["mazda-3"])
    }

    func testSearchFiltersByModel() {
        viewModel.searchText = "f-150"
        XCTAssertEqual(viewModel.vehicles.map(\.id), ["ford-f150"])
    }

    func testSearchFiltersByYear() {
        viewModel.searchText = "2023"
        XCTAssertEqual(viewModel.vehicles.map(\.id), ["honda-civic"])
    }

    func testSearchMatchesMultipleKeywordsAcrossFields() {
        viewModel.searchText = "2023 civic"
        XCTAssertEqual(viewModel.vehicles.map(\.id), ["honda-civic"])
    }

    func testSearchIsCaseInsensitive() {
        viewModel.searchText = "MAZDA"
        let upper = viewModel.vehicles.count
        viewModel.searchText = "mazda"
        XCTAssertEqual(viewModel.vehicles.count, upper)
    }

    func testSearchTrimsWhitespace() {
        viewModel.searchText = "mazda"
        let trimmed = viewModel.vehicles.count
        viewModel.searchText = "  mazda  "
        XCTAssertEqual(viewModel.vehicles.count, trimmed)
    }

    func testSearchWithNoMatchReturnsEmpty() {
        viewModel.searchText = "zzznomatch"
        XCTAssertTrue(viewModel.vehicles.isEmpty)
    }

    // MARK: - Filters

    func testBodyStyleOptionsAreSorted() {
        XCTAssertEqual(viewModel.bodyStyleOptions, ["Sedan", "Truck"])
    }

    func testBuyNowFilterReturnsVehiclesWithBuyNowPrice() {
        viewModel.showBuyNowOnly = true
        XCTAssertEqual(viewModel.vehicles.map(\.id), ["mazda-3"])
    }

    func testNoBidsFilterReturnsVehiclesWithNoBids() {
        viewModel.showNoBidsOnly = true
        XCTAssertEqual(viewModel.vehicles.map(\.id), ["ford-f150"])
    }

    func testUnder50kKmFilterReturnsLowMileageVehicles() {
        viewModel.showUnder50kKmOnly = true
        XCTAssertEqual(viewModel.vehicles.map(\.id), ["honda-civic", "mazda-3"])
    }

    func testBodyStyleFilterReturnsMatchingVehicles() {
        viewModel.selectedBodyStyle = "Truck"
        XCTAssertEqual(viewModel.vehicles.map(\.id), ["ford-f150"])
    }

    func testFiltersComposeWithSearch() {
        viewModel.showUnder50kKmOnly = true
        viewModel.selectedBodyStyle = "Sedan"
        viewModel.searchText = "honda"
        XCTAssertEqual(viewModel.vehicles.map(\.id), ["honda-civic"])
    }

    // MARK: - Sort

    func testSortYearNewest() {
        viewModel.sortOption = .yearNewest
        let years = viewModel.vehicles.map { $0.year }
        XCTAssertEqual(years, years.sorted(by: >))
    }

    func testSortYearOldest() {
        viewModel.sortOption = .yearOldest
        let years = viewModel.vehicles.map { $0.year }
        XCTAssertEqual(years, years.sorted(by: <))
    }

    func testSortOdometerLow() {
        viewModel.sortOption = .odometerLow
        let odometers = viewModel.vehicles.map { $0.odometerKm }
        XCTAssertEqual(odometers, odometers.sorted())
    }

    func testSortConditionBest() {
        viewModel.sortOption = .conditionBest
        let grades = viewModel.vehicles.map { $0.conditionGrade }
        XCTAssertEqual(grades, grades.sorted(by: >))
    }

    func testSortBidLowUsesSeededCurrentBidOrStartingBid() {
        viewModel.sortOption = .bidLow
        XCTAssertEqual(viewModel.vehicles.map(\.id), ["mazda-3", "honda-civic", "ford-f150"])
    }

    func testSortBidHighUsesLatestBidStoreState() {
        bidStore.placeBid(vehicleID: "mazda-3", amount: 25_000)
        viewModel.sortOption = .bidHigh
        XCTAssertEqual(viewModel.vehicles.map(\.id), ["mazda-3", "ford-f150", "honda-civic"])
    }

    private enum TestError: Error {
        case loadFailed
    }

    private func makeVehicle(
        id: String,
        year: Int,
        make: String,
        model: String,
        trim: String,
        bodyStyle: String,
        odometerKm: Int,
        conditionGrade: Double,
        city: String,
        auctionStart: Date,
        startingBid: Int,
        buyNowPrice: Int?,
        currentBid: Int?,
        bidCount: Int
    ) -> Vehicle {
        Vehicle(
            id: id,
            vin: "VIN-\(id)",
            year: year,
            make: make,
            model: model,
            trim: trim,
            bodyStyle: bodyStyle,
            exteriorColor: "Blue",
            interiorColor: "Black",
            engine: "2.0L",
            transmission: "Automatic",
            drivetrain: "FWD",
            odometerKm: odometerKm,
            fuelType: "Gasoline",
            conditionGrade: conditionGrade,
            conditionReport: "Clean",
            damageNotes: [],
            titleStatus: "Clean",
            province: "ON",
            city: city,
            sellingDealership: "The Block",
            lot: "LOT-\(id)",
            auctionStart: auctionStart,
            startingBid: startingBid,
            reservePrice: nil,
            buyNowPrice: buyNowPrice,
            images: [],
            currentBid: currentBid,
            bidCount: bidCount
        )
    }
}
