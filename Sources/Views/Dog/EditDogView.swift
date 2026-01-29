import SwiftUI

struct EditDogView: View {
    let packId: Int
    @Bindable var viewModel: DogViewModel
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Edit Dog Profile")
                    .font(.headline)

                Spacer()

                Button {
                    isPresented = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                        .imageScale(.large)
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background(.bar)

            Divider()

            // Form
            Form {
                Section {
                    TextField("Name", text: $viewModel.dogName)

                    TextField("Breed (optional)", text: $viewModel.dogBreed)

                    DatePicker(
                        "Birth Date",
                        selection: Binding(
                            get: { viewModel.dogBirthDate ?? Date() },
                            set: { viewModel.dogBirthDate = $0 }
                        ),
                        displayedComponents: .date
                    )
                }

                Section {
                    HStack {
                        Spacer()

                        Button("Cancel") {
                            isPresented = false
                        }
                        .buttonStyle(.bordered)

                        Button {
                            Task {
                                await viewModel.updateDog(packId: packId)
                                if viewModel.errorMessage == nil {
                                    isPresented = false
                                }
                            }
                        } label: {
                            if viewModel.isLoading {
                                ProgressView()
                                    .controlSize(.small)
                            } else {
                                Text("Save Changes")
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(viewModel.dogName.isEmpty || viewModel.isLoading)

                        Spacer()
                    }
                }
            }
            .formStyle(.grouped)
        }
        .frame(width: 500, height: 400)
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
    }
}

#Preview {
    EditDogView(packId: 1, viewModel: DogViewModel(), isPresented: .constant(true))
}
