import SwiftUI

struct CreatePackView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: PackViewModel

    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Text("Create Pack")
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

            // Form
            VStack(alignment: .leading, spacing: 8) {
                Text("Pack Name")
                    .font(.headline)

                TextField("Enter pack name", text: $viewModel.newPackName)
                    .textFieldStyle(.roundedBorder)

                Text("Choose a name for your pack. You can change it later.")
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

                Button("Create") {
                    Task {
                        await viewModel.createPack()
                        if viewModel.errorMessage == nil {
                            dismiss()
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.newPackName.isEmpty || viewModel.isLoading)
            }
        }
        .padding(24)
        .frame(width: 400, height: 280)
    }
}

#Preview {
    CreatePackView(viewModel: PackViewModel())
}
