import SwiftUI

struct JoinPackView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: PackViewModel

    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Text("Join Pack")
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

            // Info
            HStack(spacing: 12) {
                Image(systemName: "info.circle.fill")
                    .foregroundStyle(.blue)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Have an invitation?")
                        .font(.headline)
                    Text("Paste the invitation token from your email below")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(12)
            .background(.blue.opacity(0.1))
            .cornerRadius(8)

            // Form
            VStack(alignment: .leading, spacing: 8) {
                Text("Invitation Token")
                    .font(.headline)

                TextField("Paste token here", text: $viewModel.invitationToken)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(.body, design: .monospaced))

                Text("The token is a long string of characters from your invitation email")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

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

                Button("Join") {
                    Task {
                        await viewModel.acceptInvitation()
                        if viewModel.errorMessage == nil {
                            dismiss()
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.invitationToken.isEmpty || viewModel.isLoading)
            }
        }
        .padding(24)
        .frame(width: 500, height: 350)
    }
}

#Preview {
    JoinPackView(viewModel: PackViewModel())
}
