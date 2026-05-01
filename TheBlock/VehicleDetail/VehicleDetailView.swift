import SwiftUI

struct VehicleDetailView: View {
    let vehicle: Vehicle

    @StateObject private var viewModel: VehicleDetailViewModel
    @EnvironmentObject private var bidStore: BidStore

    init(vehicle: Vehicle, bidStore: BidStore) {
        self.vehicle = vehicle
        _viewModel = StateObject(wrappedValue: VehicleDetailViewModel(vehicle: vehicle, bidStore: bidStore))
    }

    private var bidState: BidState? { bidStore.state(for: vehicle.id) }
    private var currentBid: Int { bidState?.currentBid ?? vehicle.currentBid ?? vehicle.startingBid }
    private var bidCount: Int { bidState?.bidCount ?? vehicle.bidCount }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ImageGalleryView(imageURLs: vehicle.images)

                VStack(alignment: .leading, spacing: 24) {
                    headerSection
                    Divider()
                    bidSection
                    Divider()
                    specsSection
                    Divider()
                    conditionSection
                    Divider()
                    dealershipSection
                }
                .padding()
            }
        }
        .navigationTitle("\(vehicle.year) \(vehicle.make) \(vehicle.model)")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Sections

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(vehicle.year) \(vehicle.make) \(vehicle.model)")
                .font(.title2.weight(.bold))
            Text(vehicle.trim)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("\(vehicle.city), \(vehicle.province)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var bidSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Auction")
                .font(.headline)

            HStack(alignment: .firstTextBaseline) {
                Text("$\(currentBid.formatted())")
                    .font(.title.weight(.bold))
                Text("· \(bidCount) bids")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if let buyNow = vehicle.buyNowPrice {
                Text("Buy Now: $\(buyNow.formatted())")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            HStack {
                TextField("Enter bid amount", text: $viewModel.bidInput)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: viewModel.bidInput) { viewModel.resetBidStatus() }

                Button("Place Bid") {
                    viewModel.placeBid()
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.bidInput.isEmpty)
            }

            if let error = viewModel.bidError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            if viewModel.didPlaceBid {
                Text("Bid placed successfully!")
                    .font(.caption)
                    .foregroundStyle(.green)
            }
        }
    }

    private var specsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Specifications")
                .font(.headline)

            LabeledContent("Odometer", value: "\(vehicle.odometerKm.formatted()) km")
            LabeledContent("Body Style", value: vehicle.bodyStyle)
            LabeledContent("Engine", value: vehicle.engine)
            LabeledContent("Transmission", value: vehicle.transmission.capitalized)
            LabeledContent("Drivetrain", value: vehicle.drivetrain)
            LabeledContent("Fuel Type", value: vehicle.fuelType.capitalized)
            LabeledContent("Exterior", value: vehicle.exteriorColor)
            LabeledContent("Interior", value: vehicle.interiorColor)
        }
    }

    private var conditionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Condition")
                .font(.headline)

            LabeledContent("Grade", value: String(format: "%.1f / 5.0", vehicle.conditionGrade))
            LabeledContent("Title", value: vehicle.titleStatus.capitalized)

            Text(vehicle.conditionReport)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if !vehicle.damageNotes.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Damage Notes")
                        .font(.subheadline.weight(.semibold))
                    ForEach(vehicle.damageNotes, id: \.self) { note in
                        HStack(alignment: .top, spacing: 6) {
                            Text("•")
                            Text(note)
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    private var dealershipSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Dealership")
                .font(.headline)

            LabeledContent("Seller", value: vehicle.sellingDealership)
            LabeledContent("Location", value: "\(vehicle.city), \(vehicle.province)")
            LabeledContent("Lot", value: vehicle.lot)
        }
    }
}
