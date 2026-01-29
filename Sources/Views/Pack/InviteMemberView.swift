import SwiftUI

struct InviteMemberView: View {
    @Environment(\.dismiss) private var dismiss
    let packId: Int
    @Bindable var viewModel: PackViewModel

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

            if let invitation = viewModel.lastCreatedInvitation {
                // Success state - show invitation code
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.green)

                    Text("Invitation Created!")
                        .font(.title2.bold())

                    Text("Share this code with \(invitation.email)")
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)

                    // Invitation code display
                    VStack(spacing: 8) {
                        Text("Invitation Code")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        HStack {
                            Text(invitation.token)
                                .font(.system(.body, design: .monospaced))
                                .textSelection(.enabled)
                                .lineLimit(1)
                                .truncationMode(.middle)

                            Button {
                                NSPasteboard.general.clearContents()
                                NSPasteboard.general.setString(invitation.token, forType: .string)
                            } label: {
                                Image(systemName: "doc.on.doc")
                            }
                            .buttonStyle(.borderless)
                            .help("Copy to clipboard")
                        }
                        .padding(12)
                        .background(.background.secondary)
                        .cornerRadius(8)

                        Text("Expires: \(invitation.expiresAt.formatted(date: .abbreviated, time: .shortened))")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }

                    Button("Done") {
                        viewModel.lastCreatedInvitation = nil
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
                        Text("You'll get a code to share with them")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(12)
                .background(.blue.opacity(0.1))
                .cornerRadius(8)

                if let error = viewModel.errorMessage {
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

                    Button("Create Invitation") {
                        Task {
                            await viewModel.inviteMember(packId: packId)
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
