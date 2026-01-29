import Foundation
import Observation

@Observable
@MainActor
class AuthService {
    static let shared = AuthService()

    private(set) var isAuthenticated = false
    private(set) var currentUser: User?

    private init() {}

    func login(email: String, password: String) async throws {
        let request = LoginRequest(email: email, password: password)
        let response: AuthResponse = try await APIClient.shared.request(
            "/auth/login",
            method: "POST",
            body: request
        )

        // Store token in APIClient
        let logFile = "/tmp/neatdog-debug.log"
        let existing = (try? String(contentsOfFile: logFile)) ?? ""
        let msg = existing + "\n[AuthService.login] Setting token: \(response.accessToken.prefix(30))..."
        try? msg.write(toFile: logFile, atomically: false, encoding: .utf8)
        await APIClient.shared.setToken(response.accessToken)

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

        // Store token in APIClient
        await APIClient.shared.setToken(response.accessToken)

        // Update state
        self.currentUser = response.user
        self.isAuthenticated = true
    }

    func logout() async {
        // Clear token
        await APIClient.shared.setToken(nil)

        // Update state
        currentUser = nil
        isAuthenticated = false
    }
}
