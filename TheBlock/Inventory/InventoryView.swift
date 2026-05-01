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
                    VStack(spacing: 0) {
                        filterBar
                        if viewModel.hasActiveFilters {
                            ContentUnavailableView(
                                "No Matching Vehicles",
                                systemImage: "line.3.horizontal.decrease.circle",
                                description: Text("Try changing your search or filters.")
                            )
                        } else {
                            ContentUnavailableView.search(text: viewModel.searchText)
                        }
                    }
                } else {
                    ScrollView {
                        filterBar

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
            .task { viewModel.load() }
        }
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                Menu {
                    Picker("Sort by", selection: $viewModel.sortOption) {
                        ForEach(InventorySortOption.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                } label: {
                    Label("Sort", systemImage: "arrow.up.arrow.down")
                        .font(.caption.weight(.medium))
                }
                .buttonStyle(.bordered)
                .tint(.secondary)

                filterButton("Buy Now", isActive: viewModel.showBuyNowOnly) {
                    viewModel.showBuyNowOnly.toggle()
                }

                filterButton("No Bids", isActive: viewModel.showNoBidsOnly) {
                    viewModel.showNoBidsOnly.toggle()
                }

                filterButton("Under 50k km", isActive: viewModel.showUnder50kKmOnly) {
                    viewModel.showUnder50kKmOnly.toggle()
                }

                Menu {
                    Button("All Body Styles") {
                        viewModel.selectedBodyStyle = nil
                    }

                    ForEach(viewModel.bodyStyleOptions, id: \.self) { bodyStyle in
                        Button(bodyStyle.capitalized) {
                            viewModel.selectedBodyStyle = bodyStyle
                        }
                    }
                } label: {
                    Label(viewModel.selectedBodyStyle?.capitalized ?? "Body Style", systemImage: "car")
                        .font(.caption.weight(.medium))
                }
                .buttonStyle(.bordered)
                .tint(viewModel.selectedBodyStyle == nil ? .secondary : .blue)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }

    private func filterButton(_ title: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.caption.weight(.medium))
        }
        .buttonStyle(.bordered)
        .tint(isActive ? .blue : .secondary)
    }
}
