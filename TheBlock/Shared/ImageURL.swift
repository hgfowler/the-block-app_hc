import Foundation

func displayImageURL(from string: String) -> URL? {
    guard var components = URLComponents(string: string) else { return nil }

    if components.host == "placehold.co",
       !components.path.contains(".") {
        components.path += ".png"
    }

    return components.url
}
