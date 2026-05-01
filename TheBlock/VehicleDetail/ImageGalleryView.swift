import SwiftUI

struct ImageGalleryView: View {
    let imageURLs: [String]

    var body: some View {
        TabView {
            ForEach(imageURLs, id: \.self) { urlString in
                AsyncImage(url: displayImageURL(from: urlString)) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().aspectRatio(contentMode: .fill)
                    default:
                        Rectangle().fill(Color(.systemGray5))
                    }
                }
                .clipped()
            }
        }
        .tabViewStyle(.page)
        .frame(height: 280)
    }
}
