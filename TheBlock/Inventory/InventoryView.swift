import SwiftUI

struct InventoryView: View {
    @StateObject private var viewModel: InventoryViewModel
    @EnvironmentObject private var bidStore: BidStore

    init(bidStore: BidStore) {
        _viewModel = StateObject(wrappedValue: InventoryViewModel(bidStore: bidStore))
    }

    private let columns = [GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            Group {
                if let error = viewModel.loadError {
                    ContentUnavailableView(
                        "Unable to Load",
                        systemImage: "exclamationmark.triangle",
                        description: Text(error)
                    )
                } else if viewModel.vehicles.isEmpty && !viewModel.baseVehicles.isEmpty {
                    ContentUnavailableView.search(text: viewModel.searchText)
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(viewModel.vehicles) { vehicle in
                                NavigationLink {
                                    VehicleDetailView(vehicle: vehicle, bidStore: bidStore)
                                } label: {
                                    VehicleCardView(
                                        vehicle: vehicle,
                                        bidState: bidStore.state(for: vehicle.id)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("The Block")
            .searchable(text: $viewModel.searchText, prompt: "Search make, model, city…")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Picker("Sort by", selection: $viewModel.sortOption) {
                            ForEach(InventorySortOption.allCases) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                    } label: {
                        Label("Sort", systemImage: "arrow.up.arrow.down")
                    }
                }
            }
            .task { viewModel.load() }
        }
    }
}
