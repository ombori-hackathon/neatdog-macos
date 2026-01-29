import Foundation

struct ActivityLog: Codable, Identifiable {
    let id: Int
    let packId: Int
    let dogId: Int
    let activityTypeId: Int
    let userId: Int
    let notes: String?
    let loggedAt: Date
    let createdAt: Date
}

struct ActivityLogWithDetails: Codable, Identifiable {
    let id: Int
    let packId: Int
    let dogId: Int
    let activityTypeId: Int
    let userId: Int
    let notes: String?
    let loggedAt: Date
    let createdAt: Date
    let activityType: ActivityType
    let user: User
}

struct CreateActivityLogRequest: Encodable {
    let activityTypeId: Int
    let notes: String?
    let loggedAt: Date?
}
