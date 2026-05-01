import Foundation

struct VehicleRepository {
    enum RepositoryError: Error {
        case fileNotFound
    }

    static func loadAll() throws -> [Vehicle] {
        guard let url = Bundle.main.url(forResource: "vehicles", withExtension: "json") else {
            throw RepositoryError.fileNotFound
        }
        let data = try Data(contentsOf: url)
        return try vehicleDecoder.decode([Vehicle].self, from: data)
    }
}

private let vehicleDecoder: JSONDecoder = {
    let d = JSONDecoder()
    d.keyDecodingStrategy = .convertFromSnakeCase
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    d.dateDecodingStrategy = .formatted(formatter)
    return d
}()
