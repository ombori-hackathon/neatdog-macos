import SwiftUI

struct SignupView: View {
    @Binding var showSignup: Bool
    @State private var viewModel = AuthViewModel()

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Create Account")
                    .font(.title.bold())
                Spacer()
                Button {
                    showSignup = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            Spacer()

            // Signup Form
            VStack(spacing: 16) {
                TextField("Name", text: $viewModel.name)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.name)
                    .frame(width: 300)

                TextField("Email", text: $viewModel.email)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.emailAddress)
                    .autocorrectionDisabled()
                    .frame(width: 300)

                SecureField("Password", text: $viewModel.password)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.newPassword)
                    .frame(width: 300)

                Text("Password must be at least 6 characters")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(width: 300, alignment: .leading)

                // Error message
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .frame(width: 300)
                }

                // Signup button
                Button {
                    Task {
                        await viewModel.signup()
                    }
                } label: {
                    if viewModel.isLoading {
                        ProgressView()
                            .controlSize(.small)
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Sign Up")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .frame(width: 300)
                .disabled(viewModel.isLoading)
                .padding(.top, 8)

                // Login link
                HStack(spacing: 4) {
                    Text("Already have an account?")
                        .foregroundStyle(.secondary)
                    Button("Login") {
                        showSignup = false
                    }
                }
                .font(.subheadline)
                .padding(.top, 8)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .frame(width: 500, height: 600)
        .background(Color(nsColor: .windowBackgroundColor))
    }
}

#Preview {
    SignupView(showSignup: .constant(true))
}
