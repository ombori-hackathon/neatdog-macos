import Foundation

struct User: Codable, Identifiable {
    let id: Int
    let email: String
    let name: String
    let createdAt: Date
}

struct AuthToken: Codable {
    let accessToken: String
    let refreshToken: String
    let tokenType: String
}

struct LoginRequest: Encodable {
    let email: String
    let password: String
}

struct SignupRequest: Encodable {
    let email: String
    let password: String
    let name: String
}

struct AuthResponse: Codable {
    let accessToken: String
    let refreshToken: String
    let tokenType: String
    let user: User
}
