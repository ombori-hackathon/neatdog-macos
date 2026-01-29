import SwiftUI

struct LoginView: View {
    @State private var viewModel = AuthViewModel()
    @State private var showSignup = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Logo/Title
            VStack(spacing: 8) {
                Text("neatdog")
                    .font(.system(size: 48, weight: .bold))
                Text("Track your pack")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 48)

            // Login Form
            VStack(spacing: 16) {
                TextField("Email", text: $viewModel.email)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.emailAddress)
                    .autocorrectionDisabled()
                    .frame(width: 300)

                SecureField("Password", text: $viewModel.password)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.password)
                    .frame(width: 300)

                // Error message
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .frame(width: 300)
                }

                // Login button
                Button {
                    Task {
                        await viewModel.login()
                    }
                } label: {
                    if viewModel.isLoading {
                        ProgressView()
                            .controlSize(.small)
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Login")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .frame(width: 300)
                .disabled(viewModel.isLoading)

                // Signup link
                HStack(spacing: 4) {
                    Text("Don't have an account?")
                        .foregroundStyle(.secondary)
                    Button("Sign up") {
                        showSignup = true
                    }
                }
                .font(.subheadline)
                .padding(.top, 8)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .windowBackgroundColor))
        .sheet(isPresented: $showSignup) {
            SignupView(showSignup: $showSignup)
        }
    }
}

#Preview {
    LoginView()
}
