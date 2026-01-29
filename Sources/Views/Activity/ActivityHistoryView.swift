import SwiftUI

struct ActivityHistoryView: View {
    let packId: Int
    @Bindable var viewModel: ActivityViewModel

    // Group activities by date
    private var groupedActivities: [(String, [ActivityLogWithDetails])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: viewModel.activities) { activity -> String in
            if calendar.isDateInToday(activity.loggedAt) {
                return "Today"
            } else if calendar.isDateInYesterday(activity.loggedAt) {
                return "Yesterday"
            } else if calendar.isDate(activity.loggedAt, equalTo: Date(), toGranularity: .weekOfYear) {
                return activity.loggedAt.formatted(.dateTime.weekday(.wide))
            } else {
                return activity.loggedAt.formatted(date: .abbreviated, time: .omitted)
            }
        }

        // Sort by date (most recent first)
        return grouped
            .map { ($0.key, $0.value.sorted { $0.loggedAt > $1.loggedAt }) }
            .sorted { group1, group2 in
                guard let date1 = group1.1.first?.loggedAt,
                      let date2 = group2.1.first?.loggedAt else {
                    return false
                }
                return date1 > date2
            }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Filter controls
            VStack(spacing: 12) {
                HStack {
                    Text("Filter Activities")
                        .font(.headline)

                    Spacer()

                    if viewModel.selectedTypeId != nil || viewModel.startDate != nil || viewModel.endDate != nil {
                        Button("Clear Filters") {
                            viewModel.selectedTypeId = nil
                            viewModel.startDate = nil
                            viewModel.endDate = nil
                            Task {
                                await viewModel.loadActivities(packId: packId)
                            }
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(.blue)
                        .font(.caption)
                    }
                }

                HStack(spacing: 12) {
                    // Activity type filter
                    Picker("Type", selection: $viewModel.selectedTypeId) {
                        Text("All Types").tag(nil as Int?)
                        ForEach(viewModel.activityTypes) { type in
                            Text(type.name).tag(type.id as Int?)
                        }
                    }
                    .frame(width: 150)

                    // Date range
                    DatePicker("From", selection: Binding(
                        get: { viewModel.startDate ?? Date().addingTimeInterval(-7 * 24 * 60 * 60) },
                        set: { viewModel.startDate = $0 }
                    ), displayedComponents: .date)
                    .frame(width: 180)

                    DatePicker("To", selection: Binding(
                        get: { viewModel.endDate ?? Date() },
                        set: { viewModel.endDate = $0 }
                    ), displayedComponents: .date)
                    .frame(width: 180)

                    Button("Apply") {
                        Task {
                            await viewModel.loadActivities(packId: packId)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
            .background(.bar)

            Divider()

            // Activities list
            if viewModel.isLoading {
                ProgressView("Loading activities...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.activities.isEmpty {
                ContentUnavailableView(
                    "No Activities Yet",
                    systemImage: "list.bullet.clipboard",
                    description: Text("Start logging activities to see them here")
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                        ForEach(groupedActivities, id: \.0) { dateLabel, activities in
                            Section {
                                ForEach(activities) { activity in
                                    VStack(spacing: 0) {
                                        ActivityRowView(activity: activity)
                                            .padding(.horizontal)

                                        if activity.id != activities.last?.id {
                                            Divider()
                                                .padding(.leading, 64)
                                        }
                                    }
                                }
                            } header: {
                                HStack {
                                    Text(dateLabel)
                                        .font(.caption.bold())
                                        .foregroundStyle(.secondary)
                                        .textCase(.uppercase)

                                    Spacer()

                                    Text("\(activities.count) activit\(activities.count == 1 ? "y" : "ies")")
                                        .font(.caption)
                                        .foregroundStyle(.tertiary)
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                                .background(.bar)
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    let viewModel = ActivityViewModel()
    viewModel.activityTypes = [
        ActivityType(id: 1, name: "Walk", icon: "figure.walk", color: "3B82F6", packId: 1, isDefault: true, createdAt: Date()),
        ActivityType(id: 2, name: "Feed", icon: "fork.knife", color: "10B981", packId: 1, isDefault: true, createdAt: Date())
    ]
    viewModel.activities = [
        ActivityLogWithDetails(
            id: 1,
            packId: 1,
            dogId: 1,
            activityTypeId: 1,
            userId: 1,
            notes: "Great walk!",
            loggedAt: Date(),
            createdAt: Date(),
            activityType: viewModel.activityTypes[0],
            user: User(id: 1, email: "user@example.com", name: "John", createdAt: Date())
        )
    ]

    return ActivityHistoryView(packId: 1, viewModel: viewModel)
}
