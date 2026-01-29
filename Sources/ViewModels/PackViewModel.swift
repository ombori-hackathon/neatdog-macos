import Foundation
import Observation

@Observable
@MainActor
class PackViewModel {
    var packs: [Pack] = []
    var currentPack: PackWithMembers?
    var isLoading = false
    var errorMessage: String?

    // Form state
    var newPackName = ""
    var inviteEmail = ""
    var invitationToken = ""

    func loadPacks() async {
        isLoading = true
        errorMessage = nil

        do {
            packs = try await APIClient.shared.request("/packs")
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    func loadPack(id: Int) async {
        isLoading = true
        errorMessage = nil

        do {
            currentPack = try await APIClient.shared.request("/packs/\(id)")
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    func createPack() async {
        guard !newPackName.isEmpty else {
            errorMessage = "Pack name cannot be empty"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let request = CreatePackRequest(name: newPackName)
            let pack: Pack = try await APIClient.shared.request(
                "/packs",
                method: "POST",
                body: request
            )

            // Add to packs list
            packs.append(pack)

            // Clear form
            newPackName = ""
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    func inviteMember(packId: Int) async {
        guard !inviteEmail.isEmpty else {
            errorMessage = "Email cannot be empty"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let request = InviteMemberRequest(email: inviteEmail)
            let _: PackInvitation = try await APIClient.shared.request(
                "/packs/\(packId)/invitations",
                method: "POST",
                body: request
            )

            // Clear form
            inviteEmail = ""
            isLoading = false

            // Show success message
            errorMessage = "Invitation sent successfully"
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    func acceptInvitation() async {
        guard !invitationToken.isEmpty else {
            errorMessage = "Token cannot be empty"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let request = AcceptInvitationRequest(token: invitationToken)
            let _: Pack = try await APIClient.shared.request(
                "/packs/invitations/accept",
                method: "POST",
                body: request
            )

            // Clear form
            invitationToken = ""

            // Reload packs
            await loadPacks()
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
}
