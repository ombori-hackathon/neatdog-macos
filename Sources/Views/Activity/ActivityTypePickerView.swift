import SwiftUI

struct ActivityTypePickerView: View {
    let activityTypes: [ActivityType]
    let onSelect: (ActivityType) -> Void

    private let columns = [
        GridItem(.adaptive(minimum: 100, maximum: 120), spacing: 16)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Select Activity Type")
                .font(.headline)

            if activityTypes.isEmpty {
                ContentUnavailableView(
                    "No Activity Types",
                    systemImage: "list.bullet",
                    description: Text("Create custom activity types to get started")
                )
                .frame(maxWidth: .infinity, minHeight: 200)
            } else {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(activityTypes) { activityType in
                        ActivityTypeCard(activityType: activityType) {
                            onSelect(activityType)
                        }
                    }
                }
            }
        }
    }
}

struct ActivityTypeCard: View {
    let activityType: ActivityType
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                // Icon with color
                ZStack {
                    Circle()
                        .fill(Color(hex: activityType.color).gradient)
                        .frame(width: 60, height: 60)

                    Image(systemName: activityType.icon)
                        .font(.system(size: 28))
                        .foregroundStyle(.white)
                }

                // Name
                Text(activityType.name)
                    .font(.caption.weight(.medium))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .foregroundStyle(.primary)

                // Badge for default/custom
                if activityType.isDefault {
                    Text("Default")
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.blue.opacity(0.2))
                        .foregroundStyle(.blue)
                        .cornerRadius(4)
                } else {
                    Text("Custom")
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.purple.opacity(0.2))
                        .foregroundStyle(.purple)
                        .cornerRadius(4)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(.background.secondary)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.quaternary, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ActivityTypePickerView(
        activityTypes: [
            ActivityType(
                id: 1,
                name: "Walk",
                icon: "figure.walk",
                color: "#3B82F6",
                packId: nil,
                isDefault: true,
                createdAt: Date()
            ),
            ActivityType(
                id: 2,
                name: "Play",
                icon: "tennis.racket",
                color: "#10B981",
                packId: nil,
                isDefault: true,
                createdAt: Date()
            ),
            ActivityType(
                id: 3,
                name: "Training",
                icon: "brain.head.profile",
                color: "#8B5CF6",
                packId: 1,
                isDefault: false,
                createdAt: Date()
            )
        ],
        onSelect: { _ in }
    )
    .padding()
}
