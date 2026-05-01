import Foundation

class InventoryViewModel: ObservableObject {
    @Published private(set) var baseVehicles: [Vehicle] = []
    @Published var searchText = ""
    @Published var sortOption: InventorySortOption = .yearNewest
    @Published var showBuyNowOnly = false
    @Published var showNoBidsOnly = false
    @Published var showUnder50kKmOnly = false
    @Published var selectedBodyStyle: String?
    @Published private(set) var loadError: String?

    private let bidStore: BidStore
    private let vehicleLoader: () throws -> [Vehicle]

    init(
        bidStore: BidStore,
        vehicleLoader: @escaping () throws -> [Vehicle] = VehicleRepository.loadAll
    ) {
        self.bidStore = bidStore
        self.vehicleLoader = vehicleLoader
    }

    var vehicles: [Vehicle] {
        let filtered = baseVehicles.filter(matchesSearch).filter(matchesFilters)
        return sorted(filtered)
    }

    var bodyStyleOptions: [String] {
        Array(Set(baseVehicles.map(\.bodyStyle))).sorted {
            $0.localizedCaseInsensitiveCompare($1) == .orderedAscending
        }
    }

    var hasActiveFilters: Bool {
        showBuyNowOnly || showNoBidsOnly || showUnder50kKmOnly || selectedBodyStyle != nil
    }

    func load() {
        do {
            baseVehicles = try vehicleLoader()
            bidStore.seed(from: baseVehicles)
            loadError = nil
        } catch {
            loadError = error.localizedDescription
        }
    }

    private func matchesSearch(_ vehicle: Vehicle) -> Bool {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !query.isEmpty else { return true }

        let searchTerms = query.split(separator: " ").map(String.init)
        let searchableFields = [
            vehicle.make,
            vehicle.model,
            String(vehicle.year),
            vehicle.city,
            vehicle.trim
        ].map { $0.lowercased() }

        return searchTerms.allSatisfy { term in
            searchableFields.contains { $0.contains(term) }
        }
    }

    private func matchesFilters(_ vehicle: Vehicle) -> Bool {
        if showBuyNowOnly && vehicle.buyNowPrice == nil {
            return false
        }

        if showNoBidsOnly && currentBidCount(vehicle) != 0 {
            return false
        }

        if showUnder50kKmOnly && vehicle.odometerKm >= 50_000 {
            return false
        }

        if let selectedBodyStyle,
           vehicle.bodyStyle.localizedCaseInsensitiveCompare(selectedBodyStyle) != .orderedSame {
            return false
        }

        return true
    }

    private func sorted(_ list: [Vehicle]) -> [Vehicle] {
        switch sortOption {
        case .yearNewest:    return list.sorted { $0.year > $1.year }
        case .yearOldest:    return list.sorted { $0.year < $1.year }
        case .bidLow:        return list.sorted { currentBid($0) < currentBid($1) }
        case .bidHigh:       return list.sorted { currentBid($0) > currentBid($1) }
        case .conditionBest: return list.sorted { $0.conditionGrade > $1.conditionGrade }
        case .odometerLow:   return list.sorted { $0.odometerKm < $1.odometerKm }
        }
    }

    private func currentBid(_ vehicle: Vehicle) -> Int {
        bidStore.state(for: vehicle.id)?.currentBid ?? vehicle.currentBid ?? vehicle.startingBid
    }

    private func currentBidCount(_ vehicle: Vehicle) -> Int {
        bidStore.state(for: vehicle.id)?.bidCount ?? vehicle.bidCount
    }
}
