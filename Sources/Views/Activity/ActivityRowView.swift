import SwiftUI

struct ActivityRowView: View {
    let activity: ActivityLogWithDetails

    var body: some View {
        HStack(spacing: 12) {
            // Activity icon with color
            Circle()
                .fill(Color(hex: activity.activityType.color))
                .frame(width: 40, height: 40)
                .overlay {
                    Image(systemName: activity.activityType.icon)
                        .foregroundStyle(.white)
                        .font(.system(size: 18, weight: .semibold))
                }

            VStack(alignment: .leading, spacing: 4) {
                // Activity name and relative time
                HStack(spacing: 8) {
                    Text(activity.activityType.name)
                        .font(.headline)

                    Spacer()

                    Text(activity.loggedAt.relativeTimeString())
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                // User who logged it
                Text("Logged by \(activity.user.name)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                // Notes if present
                if let notes = activity.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .lineLimit(2)
                        .padding(.top, 2)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    let sampleActivity = ActivityLogWithDetails(
        id: 1,
        packId: 1,
        dogId: 1,
        activityTypeId: 1,
        userId: 1,
        notes: "Had a great walk in the park!",
        loggedAt: Date().addingTimeInterval(-3600),
        createdAt: Date().addingTimeInterval(-3600),
        activityType: ActivityType(
            id: 1,
            name: "Walk",
            icon: "figure.walk",
            color: "3B82F6",
            packId: 1,
            isDefault: true,
            createdAt: Date()
        ),
        user: User(
            id: 1,
            email: "user@example.com",
            name: "John Doe",
            createdAt: Date()
        )
    )

    return ActivityRowView(activity: sampleActivity)
        .padding()
}
