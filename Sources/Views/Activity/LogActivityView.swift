import SwiftUI

struct LogActivityView: View {
    @Environment(\.dismiss) private var dismiss
    let packId: Int
    @Bindable var viewModel: ActivityViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Log Activity")
                    .font(.title2.bold())

                Spacer()

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background(.bar)

            Divider()

            ScrollView(.vertical) {
                VStack(spacing: 24) {
                    // Activity type picker
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Activity Type")
                            .font(.headline)

                        LazyVGrid(columns: [
                            GridItem(.adaptive(minimum: 100, maximum: 120))
                        ], spacing: 12) {
                            ForEach(viewModel.activityTypes) { activityType in
                                Button {
                                    viewModel.selectedActivityType = activityType
                                } label: {
                                    VStack(spacing: 8) {
                                        Circle()
                                            .fill(Color(hex: activityType.color))
                                            .frame(width: 50, height: 50)
                                            .overlay {
                                                Image(systemName: activityType.icon)
                                                    .foregroundStyle(.white)
                                                    .font(.system(size: 24, weight: .semibold))
                                            }

                                        Text(activityType.name)
                                            .font(.caption)
                                            .foregroundStyle(.primary)
                                            .lineLimit(1)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(viewModel.selectedActivityType?.id == activityType.id ? Color.accentColor.opacity(0.1) : Color.clear)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(viewModel.selectedActivityType?.id == activityType.id ? Color.accentColor : Color.clear, lineWidth: 2)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    // Date/time picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Date & Time")
                            .font(.headline)

                        DatePicker(
                            "When",
                            selection: $viewModel.loggedAt,
                            in: ...Date(),
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .datePickerStyle(.compact)
                    }

                    // Notes field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes (Optional)")
                            .font(.headline)

                        TextEditor(text: $viewModel.notes)
                            .frame(height: 100)
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(.textBackgroundColor))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(.separatorColor), lineWidth: 1)
                            )
                    }
                }
                .padding()
            }

            Divider()

            // Footer with action buttons
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.escape)

                Spacer()

                Button {
                    Task {
                        await viewModel.logActivity(packId: packId)
                        if viewModel.errorMessage == nil {
                            dismiss()
                        }
                    }
                } label: {
                    if viewModel.isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                            .frame(width: 80)
                    } else {
                        Text("Log Activity")
                            .frame(width: 100)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.selectedActivityType == nil || viewModel.isLoading)
                .keyboardShortcut(.return)
            }
            .padding()
            .background(.bar)
        }
        .frame(width: 500, height: 600)
    }
}

#Preview {
    let viewModel = ActivityViewModel()
    viewModel.activityTypes = [
        ActivityType(id: 1, name: "Walk", icon: "figure.walk", color: "3B82F6", packId: 1, isDefault: true, createdAt: Date()),
        ActivityType(id: 2, name: "Feed", icon: "fork.knife", color: "10B981", packId: 1, isDefault: true, createdAt: Date()),
        ActivityType(id: 3, name: "Play", icon: "ball.baseball", color: "F59E0B", packId: 1, isDefault: true, createdAt: Date()),
        ActivityType(id: 4, name: "Vet", icon: "cross.case", color: "EF4444", packId: 1, isDefault: true, createdAt: Date())
    ]

    return LogActivityView(packId: 1, viewModel: viewModel)
}
