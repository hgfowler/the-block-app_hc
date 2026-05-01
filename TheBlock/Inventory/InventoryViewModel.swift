import Foundation

class InventoryViewModel: ObservableObject {
    @Published private(set) var baseVehicles: [Vehicle] = []
    @Published var searchText = ""
    @Published var sortOption: InventorySortOption = .yearNewest
    @Published private(set) var loadError: String?

    private let bidStore: BidStore

    init(bidStore: BidStore) {
        self.bidStore = bidStore
    }

    var vehicles: [Vehicle] {
        let filtered = searchText.isEmpty ? baseVehicles : baseVehicles.filter(matches)
        return sorted(filtered)
    }

    func load() {
        do {
            baseVehicles = try VehicleRepository.loadAll()
            bidStore.seed(from: baseVehicles)
            loadError = nil
        } catch {
            loadError = error.localizedDescription
        }
    }

    private func matches(_ vehicle: Vehicle) -> Bool {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return vehicle.make.lowercased().contains(query)
            || vehicle.model.lowercased().contains(query)
            || String(vehicle.year).contains(query)
            || vehicle.city.lowercased().contains(query)
            || vehicle.trim.lowercased().contains(query)
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
        bidStore.state(for: vehicle.id)?.currentBid ?? vehicle.currentBid
    }
}
