import Foundation

enum InventorySortOption: String, CaseIterable, Identifiable {
    case yearNewest    = "Year: Newest"
    case yearOldest    = "Year: Oldest"
    case bidLow        = "Bid: Low to High"
    case bidHigh       = "Bid: High to Low"
    case conditionBest = "Condition: Best"
    case odometerLow   = "Odometer: Low"

    var id: String { rawValue }
}
