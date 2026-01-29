import SwiftUI

struct ActivityDashboardView: View {
    let packId: Int
    @State private var viewModel = ActivityViewModel()
    @State private var showLogActivity = false

    // Common activities to show as quick log buttons
    private var quickLogActivities: [ActivityType] {
        viewModel.activityTypes.filter { type in
            ["Walk", "Feed", "Play", "Potty", "Medication"].contains(type.name)
        }.prefix(5).map { $0 }
    }

    // Recent activities (last 10)
    private var recentActivities: [ActivityLogWithDetails] {
        Array(viewModel.activities.prefix(10))
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header with Log Activity button
            HStack {
                Text("Activity Log")
                    .font(.title2.bold())

                Spacer()

                Button {
                    showLogActivity = true
                } label: {
                    Label("Log Activity", systemImage: "plus.circle.fill")
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(.bar)

            Divider()

            ScrollView {
                VStack(spacing: 24) {
                    // Quick log section
                    if !quickLogActivities.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Quick Log")
                                .font(.headline)
                                .padding(.horizontal)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(quickLogActivities) { activityType in
                                        Button {
                                            Task { @MainActor in
                                                await viewModel.quickLog(packId: packId, activityType: activityType)
                                            }
                                        } label: {
                                            VStack(spacing: 8) {
                                                Circle()
                                                    .fill(Color(hex: activityType.color))
                                                    .frame(width: 60, height: 60)
                                                    .overlay {
                                                        Image(systemName: activityType.icon)
                                                            .foregroundStyle(.white)
                                                            .font(.system(size: 28, weight: .semibold))
                                                    }

                                                Text(activityType.name)
                                                    .font(.caption)
                                                    .foregroundStyle(.primary)
                                            }
                                            .frame(width: 90)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }

                    Divider()

                    // Recent activities section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Recent Activities")
                                .font(.headline)

                            Spacer()

                            NavigationLink {
                                ActivityHistoryView(packId: packId, viewModel: viewModel)
                            } label: {
                                Text("View All")
                                    .font(.caption)
                            }
                        }
                        .padding(.horizontal)

                        if viewModel.isLoading {
                            ProgressView("Loading activities...")
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else if recentActivities.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "list.bullet.clipboard")
                                    .font(.system(size: 48))
                                    .foregroundStyle(.secondary)

                                Text("No activities logged yet")
                                    .font(.headline)
                                    .foregroundStyle(.secondary)

                                Text("Tap 'Log Activity' to start tracking")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        } else {
                            VStack(spacing: 0) {
                                ForEach(recentActivities) { activity in
                                    VStack(spacing: 0) {
                                        ActivityRowView(activity: activity)
                                            .padding(.horizontal)

                                        if activity.id != recentActivities.last?.id {
                                            Divider()
                                                .padding(.leading, 64)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showLogActivity) {
            LogActivityView(packId: packId, viewModel: viewModel)
        }
        .task {
            await viewModel.loadActivityTypes(packId: packId)
            await viewModel.loadActivities(packId: packId)
        }
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
    NavigationStack {
        ActivityDashboardView(packId: 1)
    }
}
