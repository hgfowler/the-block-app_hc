import SwiftUI

struct VehicleCardView: View {
    let vehicle: Vehicle
    let bidState: BidState?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            AsyncImage(url: URL(string: vehicle.images.first ?? "")) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().aspectRatio(contentMode: .fill)
                default:
                    Rectangle().fill(Color(.systemGray5))
                }
            }
            .frame(height: 110)
            .clipped()

            VStack(alignment: .leading, spacing: 4) {
                Text("\(vehicle.year) \(vehicle.make)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(vehicle.model)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)

                HStack(alignment: .firstTextBaseline) {
                    Text("$\(currentBid.formatted())")
                        .font(.subheadline.weight(.bold))
                    Spacer()
                    Text("\(bidCount) bids")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(10)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 2)
    }

    private var currentBid: Int {
        bidState?.currentBid ?? vehicle.currentBid
    }

    private var bidCount: Int {
        bidState?.bidCount ?? vehicle.bidCount
    }
}
