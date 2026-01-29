import Foundation

struct Pack: Codable, Identifiable {
    let id: Int
    let name: String
    let createdBy: Int
    let createdAt: Date
}

struct PackWithMembers: Codable, Identifiable {
    let id: Int
    let name: String
    let createdBy: Int
    let createdAt: Date
    let members: [PackMember]
}

struct PackMember: Codable, Identifiable {
    let id: Int
    let userId: Int
    let role: String
    let joinedAt: Date
    let user: User
}

struct PackInvitation: Codable, Identifiable {
    let id: Int
    let email: String
    let expiresAt: Date
    let createdAt: Date
}

// Request types
struct CreatePackRequest: Encodable {
    let name: String
}

struct InviteMemberRequest: Encodable {
    let email: String
}

struct AcceptInvitationRequest: Encodable {
    let token: String
}
