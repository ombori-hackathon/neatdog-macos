import SwiftUI

struct DogProfileView: View {
    let packId: Int
    @Bindable var viewModel: DogViewModel
    @State private var showEditSheet = false

    private func calculateAge(from birthDate: Date?) -> String {
        guard let birthDate = birthDate else { return "" }

        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: birthDate, to: Date())

        if let years = components.year, let months = components.month {
            if years > 0 {
                return years == 1 ? "1 year old" : "\(years) years old"
            } else if months > 0 {
                return months == 1 ? "1 month old" : "\(months) months old"
            } else {
                return "Newborn"
            }
        }
        return ""
    }

    var body: some View {
        VStack(spacing: 24) {
            if let dog = viewModel.dog {
                // Dog avatar
                Circle()
                    .fill(.blue.gradient)
                    .frame(width: 120, height: 120)
                    .overlay {
                        Image(systemName: "pawprint.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(.white)
                    }
                    .shadow(radius: 10)

                // Dog info
                VStack(spacing: 8) {
                    Text(dog.name)
                        .font(.title.bold())

                    HStack(spacing: 16) {
                        if let breed = dog.breed, !breed.isEmpty {
                            HStack(spacing: 4) {
                                Image(systemName: "tag.fill")
                                    .font(.caption)
                                Text(breed)
                            }
                            .foregroundStyle(.secondary)
                        }

                        if dog.birthDate != nil {
                            HStack(spacing: 4) {
                                Image(systemName: "calendar")
                                    .font(.caption)
                                Text(calculateAge(from: dog.birthDate))
                            }
                            .foregroundStyle(.secondary)
                        }
                    }
                    .font(.subheadline)
                }

                Divider()
                    .padding(.vertical, 8)

                // Quick stats section (placeholder)
                VStack(alignment: .leading, spacing: 12) {
                    Text("Quick Stats")
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 20) {
                        StatCard(title: "Activities", value: "0")
                        StatCard(title: "This Week", value: "0")
                        StatCard(title: "Streak", value: "0")
                    }
                }
                .padding()
                .background(.background.secondary)
                .cornerRadius(12)

                // Edit button
                Button {
                    showEditSheet = true
                } label: {
                    Label("Edit Profile", systemImage: "pencil")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)

                Spacer()
            } else {
                ProgressView("Loading dog profile...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .padding()
        .sheet(isPresented: $showEditSheet) {
            EditDogView(packId: packId, viewModel: viewModel, isPresented: $showEditSheet)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.bold())
                .foregroundStyle(.primary)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(.background)
        .cornerRadius(8)
    }
}

#Preview {
    DogProfileView(packId: 1, viewModel: DogViewModel())
}
