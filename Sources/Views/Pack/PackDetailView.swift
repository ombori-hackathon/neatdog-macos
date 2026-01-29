import SwiftUI

struct PackDetailView: View {
    @Environment(AuthService.self) private var authService
    let packId: Int

    @State private var viewModel = PackViewModel()
    @State private var showInviteMember = false

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

                // Members list
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

                    Section("Quick Actions") {
                        NavigationLink {
                            Text("Dogs coming soon...")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } label: {
                            Label("Manage Dogs", systemImage: "pawprint.fill")
                        }

                        NavigationLink {
                            Text("Activities coming soon...")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } label: {
                            Label("View Activities", systemImage: "list.bullet")
                        }
                    }
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
    PackDetailView(packId: 1)
}
