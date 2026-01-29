import Foundation

struct ActivityType: Codable, Identifiable {
    let id: Int
    let name: String
    let icon: String  // SF Symbol name
    let color: String // hex color
    let packId: Int?
    let isDefault: Bool
    let createdAt: Date
}

struct CreateActivityTypeRequest: Encodable {
    let name: String
    let icon: String
    let color: String
}
