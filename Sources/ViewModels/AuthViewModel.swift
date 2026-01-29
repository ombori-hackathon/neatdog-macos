import Foundation
import Observation

@Observable
@MainActor
class AuthViewModel {
    var email = ""
    var password = ""
    var name = ""
    var isLoading = false
    var errorMessage: String?

    private let authService = AuthService.shared

    func login() async {
        guard validate(requireName: false) else { return }

        isLoading = true
        errorMessage = nil

        do {
            try await authService.login(email: email, password: password)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func signup() async {
        guard validate(requireName: true) else { return }

        isLoading = true
        errorMessage = nil

        do {
            try await authService.signup(email: email, password: password, name: name)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    private func validate(requireName: Bool) -> Bool {
        // Basic email validation
        guard !email.isEmpty, email.contains("@") else {
            errorMessage = "Please enter a valid email address"
            return false
        }

        // Password validation
        guard !password.isEmpty, password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters"
            return false
        }

        // Name validation for signup
        if requireName {
            guard !name.isEmpty else {
                errorMessage = "Please enter your name"
                return false
            }
        }

        return true
    }

    func clearError() {
        errorMessage = nil
    }
}
