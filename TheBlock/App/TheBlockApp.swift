import SwiftUI

@main
struct TheBlockApp: App {
    @StateObject private var bidStore = BidStore()

    var body: some Scene {
        WindowGroup {
            InventoryView()
                .environmentObject(bidStore)
        }
    }
}
