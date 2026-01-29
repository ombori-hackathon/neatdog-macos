import SwiftUI

struct PackDetailView: View {
    @Environment(AuthService.self) private var authService
    let packId: Int

    @State private var viewModel = PackViewModel()
    @State private var dogViewModel = DogViewModel()
    @State private var showInviteMember = false
    @State private var selectedTab = "members"

    var isOwner: Bool {
        if let pack = viewModel.currentPack,
           let currentUser = authService.currentUser {
            return pack.createdBy == currentUser.id
        }
        return false
    }

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isLoading {
                ProgressView("Loading pack details...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let pack = viewModel.currentPack {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(pack.name)
                            .font(.title.bold())
                        Text("\(pack.members.count) member\(pack.members.count == 1 ? "" : "s")")
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    if isOwner {
                        Button {
                            showInviteMember = true
                        } label: {
                            Label("Invite Member", systemImage: "person.badge.plus")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding()
                .background(.bar)

                Divider()

                // Tab selector
                Picker("View", selection: $selectedTab) {
                    Text("Members").tag("members")
                    Text("Dog").tag("dog")
                    Text("Activities").tag("activities")
                }
                .pickerStyle(.segmented)
                .padding()

                Divider()

                // Tab content
                if selectedTab == "members" {
                    membersList
                } else if selectedTab == "dog" {
                    dogView
                } else {
                    activitiesPlaceholder
                }
            } else {
                ContentUnavailableView(
                    "Pack Not Found",
                    systemImage: "exclamationmark.triangle",
                    description: Text("This pack could not be loaded")
                )
            }
        }
        .sheet(isPresented: $showInviteMember) {
            InviteMemberView(packId: packId, viewModel: viewModel)
        }
        .task {
            await viewModel.loadPack(id: packId)
            await dogViewModel.loadDog(packId: packId)
            await dogViewModel.loadActivityTypes(packId: packId)
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil || dogViewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
                dogViewModel.errorMessage = nil
            }
        } message: {
            if let error = viewModel.errorMessage ?? dogViewModel.errorMessage {
                Text(error)
            }
        }
    }

    // MARK: - Members List
    @ViewBuilder
    private var membersList: some View {
        if let pack = viewModel.currentPack {
            List {
                Section("Members") {
                    ForEach(pack.members) { member in
                        HStack(spacing: 12) {
                            Circle()
                                .fill(.blue.gradient)
                                .frame(width: 40, height: 40)
                                .overlay {
                                    Text(String(member.user.name.prefix(1)))
                                        .foregroundStyle(.white)
                                        .font(.headline)
                                }

                            VStack(alignment: .leading, spacing: 2) {
                                HStack(spacing: 8) {
                                    Text(member.user.name)
                                        .font(.headline)

                                    if member.role == "owner" {
                                        Text("Owner")
                                            .font(.caption2)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(.blue)
                                            .foregroundStyle(.white)
                                            .cornerRadius(4)
                                    } else if member.role == "admin" {
                                        Text("Admin")
                                            .font(.caption2)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(.purple)
                                            .foregroundStyle(.white)
                                            .cornerRadius(4)
                                    }
                                }

                                Text(member.user.email)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)

                                Text("Joined \(member.joinedAt.formatted(date: .abbreviated, time: .omitted))")
                                    .font(.caption2)
                                    .foregroundStyle(.tertiary)
                            }

                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
    }

    // MARK: - Dog View
    @ViewBuilder
    private var dogView: some View {
        if dogViewModel.isLoading {
            ProgressView("Loading dog...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if dogViewModel.hasDog {
            DogProfileView(packId: packId, viewModel: dogViewModel)
        } else {
            DogSetupView(packId: packId, viewModel: dogViewModel)
        }
    }

    // MARK: - Activities Placeholder
    @ViewBuilder
    private var activitiesPlaceholder: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "list.bullet.clipboard")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("Activities Coming Soon")
                .font(.title2.bold())

            Text("Activity logging will be available in the next phase")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    PackDetailView(packId: 1)
}
