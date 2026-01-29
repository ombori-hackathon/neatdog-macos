import SwiftUI

struct DogSetupView: View {
    let packId: Int
    @Bindable var viewModel: DogViewModel

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Icon
            Image(systemName: "pawprint.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.blue.gradient)
                .symbolEffect(.bounce, value: viewModel.isLoading)

            // Welcome message
            VStack(spacing: 8) {
                Text("Add Your Dog")
                    .font(.title.bold())

                Text("Let's get started by adding your furry friend to this pack")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            // Form
            VStack(spacing: 16) {
                // Dog name (required)
                VStack(alignment: .leading, spacing: 6) {
                    Text("Name")
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    TextField("Max, Bella, Charlie...", text: $viewModel.dogName)
                        .textFieldStyle(.roundedBorder)
                }

                // Breed (optional)
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Breed")
                            .font(.headline)
                            .foregroundStyle(.secondary)

                        Text("(optional)")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }

                    TextField("Golden Retriever, Mixed...", text: $viewModel.dogBreed)
                        .textFieldStyle(.roundedBorder)
                }

                // Birth date (optional)
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Birth Date")
                            .font(.headline)
                            .foregroundStyle(.secondary)

                        Text("(optional)")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }

                    DatePicker(
                        "Birth Date",
                        selection: Binding(
                            get: { viewModel.dogBirthDate ?? Date() },
                            set: { viewModel.dogBirthDate = $0 }
                        ),
                        displayedComponents: .date
                    )
                    .labelsHidden()
                    .datePickerStyle(.field)
                }
            }
            .padding(20)
            .frame(maxWidth: 400)
            .background(.background.secondary)
            .cornerRadius(12)

            // Add button
            Button {
                Task {
                    await viewModel.createDog(packId: packId)
                }
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                        .controlSize(.small)
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Add Dog")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .frame(maxWidth: 400)
            .disabled(viewModel.dogName.isEmpty || viewModel.isLoading)

            Spacer()
        }
        .padding()
    }
}

#Preview {
    DogSetupView(packId: 1, viewModel: DogViewModel())
}
