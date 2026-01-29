import SwiftUI

struct PackListView: View {
    @Environment(AuthService.self) private var authService
    @State private var viewModel = PackViewModel()
    @State private var showCreatePack = false
    @State private var showJoinPack = false
    @State private var selectedPackId: Int?

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("My Packs")
                    .font(.title.bold())
                Spacer()

                // User info
                if let user = authService.currentUser {
                    HStack(spacing: 12) {
                        Text(user.name)
                            .foregroundStyle(.secondary)

                        Button("Logout") {
                            Task {
                                await authService.logout()
                            }
                        }
                        .buttonStyle(.borderless)
                        .foregroundStyle(.red)
                    }
                }
            }
            .padding()
            .background(.bar)

            Divider()

            // Content
            if viewModel.isLoading {
                ProgressView("Loading packs...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.packs.isEmpty {
                // Empty state
                VStack(spacing: 16) {
                    Image(systemName: "person.3")
                        .font(.system(size: 64))
                        .foregroundStyle(.secondary)

                    Text("No Packs Yet")
                        .font(.title2.bold())

                    Text("Create a pack to start tracking dogs with your friends and family")
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 400)

                    HStack(spacing: 12) {
                        Button {
                            showCreatePack = true
                        } label: {
                            Label("Create Pack", systemImage: "plus.circle.fill")
                        }
                        .buttonStyle(.borderedProminent)

                        Button {
                            showJoinPack = true
                        } label: {
                            Label("Join Pack", systemImage: "envelope")
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // Pack list
                VStack(spacing: 0) {
                    // Toolbar
                    HStack {
                        Spacer()

                        Button {
                            showJoinPack = true
                        } label: {
                            Label("Join Pack", systemImage: "envelope")
                        }
                        .buttonStyle(.bordered)

                        Button {
                            showCreatePack = true
                        } label: {
                            Label("Create Pack", systemImage: "plus")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()

                    Divider()

                    // Pack list
                    List(viewModel.packs, selection: $selectedPackId) { pack in
                        NavigationLink(value: pack.id) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(pack.name)
                                    .font(.headline)

                                Text("Created \(pack.createdAt.formatted(date: .abbreviated, time: .omitted))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
        }
        .navigationDestination(for: Int.self) { packId in
            PackDetailView(packId: packId)
        }
        .sheet(isPresented: $showCreatePack) {
            CreatePackView(viewModel: viewModel)
        }
        .sheet(isPresented: $showJoinPack) {
            JoinPackView(viewModel: viewModel)
        }
        .task {
            await viewModel.loadPacks()
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
    PackListView()
}
