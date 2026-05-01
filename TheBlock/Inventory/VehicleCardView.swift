import SwiftUI

struct VehicleCardView: View {
    let vehicle: Vehicle
    let bidState: BidState?

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            AsyncImage(url: displayImageURL(from: vehicle.images.first ?? "")) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().aspectRatio(contentMode: .fill)
                default:
                    Rectangle().fill(Color(.systemGray5))
                }
            }
            .frame(width: 128, height: 96)
            .clipped()

            VStack(alignment: .leading, spacing: 5) {
                Text("\(vehicle.year) \(vehicle.make)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text("\(vehicle.model) \(vehicle.trim)")
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)

                Text("\(vehicle.city), \(vehicle.province)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                HStack {
                    Text("\(vehicle.odometerKm.formatted()) km")
                    Spacer()
                    Text(String(format: "%.1f / 5", vehicle.conditionGrade))
                }
                .font(.caption2)
                .foregroundStyle(.secondary)

                HStack(alignment: .firstTextBaseline) {
                    Text("$\(currentBid.formatted())")
                        .font(.subheadline.weight(.bold))
                    Spacer()
                    Text("\(bidCount) bids")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if let buyNow = vehicle.buyNowPrice {
                    Text("Buy Now $\(buyNow.formatted())")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.blue)
                }
            }
        }
        .padding(10)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 2)
    }

    private var currentBid: Int {
        bidState?.currentBid ?? vehicle.currentBid ?? vehicle.startingBid
    }

    private var bidCount: Int {
        bidState?.bidCount ?? vehicle.bidCount
    }
}
