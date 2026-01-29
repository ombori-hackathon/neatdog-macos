import Foundation
import Observation

@Observable
@MainActor
class AuthService {
    static let shared = AuthService()

    private(set) var isAuthenticated = false
    private(set) var currentUser: User?

    private init() {
        Task {
            await loadStoredAuth()
        }
    }

    func login(email: String, password: String) async throws {
        let request = LoginRequest(email: email, password: password)
        let response: AuthResponse = try await APIClient.shared.request(
            "/auth/login",
            method: "POST",
            body: request
        )

        // Store tokens
        try KeychainService.save(key: "access_token", value: response.accessToken)
        try KeychainService.save(key: "refresh_token", value: response.refreshToken)

        // Update state
        self.currentUser = response.user
        self.isAuthenticated = true
    }

    func signup(email: String, password: String, name: String) async throws {
        let request = SignupRequest(email: email, password: password, name: name)
        let response: AuthResponse = try await APIClient.shared.request(
            "/auth/signup",
            method: "POST",
            body: request
        )

        // Store tokens
        try KeychainService.save(key: "access_token", value: response.accessToken)
        try KeychainService.save(key: "refresh_token", value: response.refreshToken)

        // Update state
        self.currentUser = response.user
        self.isAuthenticated = true
    }

    func logout() {
        // Clear tokens
        KeychainService.delete(key: "access_token")
        KeychainService.delete(key: "refresh_token")

        // Update state
        currentUser = nil
        isAuthenticated = false
    }

    func refreshToken() async throws {
        guard let refreshToken = KeychainService.load(key: "refresh_token") else {
            throw AuthError.noRefreshToken
        }

        let request = RefreshTokenRequest(refreshToken: refreshToken)
        let response: AuthResponse = try await APIClient.shared.request(
            "/auth/refresh",
            method: "POST",
            body: request
        )

        // Update tokens
        try KeychainService.save(key: "access_token", value: response.accessToken)
        try KeychainService.save(key: "refresh_token", value: response.refreshToken)

        // Update state
        self.currentUser = response.user
        self.isAuthenticated = true
    }

    func loadStoredAuth() async {
        // Check if we have a stored access token
        guard KeychainService.load(key: "access_token") != nil else {
            return
        }

        // Try to get current user with stored token
        do {
            let user: User = try await APIClient.shared.request("/auth/me")
            self.currentUser = user
            self.isAuthenticated = true
        } catch {
            // Token might be expired, try to refresh
            do {
                try await refreshToken()
            } catch {
                // Refresh failed, clear everything
                logout()
            }
        }
    }
}

enum AuthError: Error, LocalizedError {
    case noRefreshToken

    var errorDescription: String? {
        switch self {
        case .noRefreshToken:
            return "No refresh token available"
        }
    }
}

private struct RefreshTokenRequest: Encodable {
    let refreshToken: String
}
