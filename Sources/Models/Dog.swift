import Foundation

struct Dog: Codable, Identifiable {
    let id: Int
    let packId: Int
    let name: String
    let breed: String?
    let birthDate: Date?
    let photoUrl: String?
    let createdAt: Date
}

struct CreateDogRequest: Encodable {
    let name: String
    let breed: String?
    let birthDate: Date?
    let photoUrl: String?
}

struct UpdateDogRequest: Encodable {
    let name: String?
    let breed: String?
    let birthDate: Date?
    let photoUrl: String?
}
