import SwiftUI

struct InviteMemberView: View {
    @Environment(\.dismiss) private var dismiss
    let packId: Int
    @Bindable var viewModel: PackViewModel

    @State private var showSuccess = false

    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Text("Invite Member")
                    .font(.title2.bold())
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                        .font(.title2)
                }
                .buttonStyle(.plain)
            }

            Divider()

            if showSuccess {
                // Success state
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(.green)

                    Text("Invitation Sent!")
                        .font(.title2.bold())

                    Text("An invitation has been sent to \(viewModel.inviteEmail)")
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)

                    Button("Done") {
                        showSuccess = false
                        viewModel.inviteEmail = ""
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 8)
                }
                .frame(maxHeight: .infinity)
            } else {
                // Form
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email Address")
                        .font(.headline)

                    TextField("member@example.com", text: $viewModel.inviteEmail)
                        .textFieldStyle(.roundedBorder)

                    Text("Enter the email address of the person you want to invite")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 12) {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(.blue)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("They will receive an invitation link via email")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(12)
                .background(.blue.opacity(0.1))
                .cornerRadius(8)

                if let error = viewModel.errorMessage, error != "Invitation sent successfully" {
                    Text(error)
                        .foregroundStyle(.red)
                        .font(.caption)
                }

                Spacer()

                // Buttons
                HStack {
                    Button("Cancel") {
                        dismiss()
                    }
                    .buttonStyle(.bordered)

                    Spacer()

                    Button("Send Invitation") {
                        Task {
                            await viewModel.inviteMember(packId: packId)
                            if viewModel.errorMessage == "Invitation sent successfully" {
                                showSuccess = true
                            }
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.inviteEmail.isEmpty || viewModel.isLoading)
                }
            }
        }
        .padding(24)
        .frame(width: 450, height: 360)
    }
}

#Preview {
    InviteMemberView(packId: 1, viewModel: PackViewModel())
}
