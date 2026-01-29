import Foundation

@Observable
@MainActor
class ActivityViewModel {
    var activities: [ActivityLogWithDetails] = []
    var activityTypes: [ActivityType] = []
    var isLoading = false
    var errorMessage: String?

    // Filter state
    var selectedTypeId: Int?
    var startDate: Date?
    var endDate: Date?

    // Log form state
    var selectedActivityType: ActivityType?
    var notes = ""
    var loggedAt = Date()

    // Load activities with optional filters
    func loadActivities(packId: Int) async {
        isLoading = true
        errorMessage = nil

        do {
            // Build query parameters
            var queryParams: [String] = []
            if let typeId = selectedTypeId {
                queryParams.append("activity_type_id=\(typeId)")
            }
            if let start = startDate {
                let formatter = ISO8601DateFormatter()
                queryParams.append("start_date=\(formatter.string(from: start))")
            }
            if let end = endDate {
                let formatter = ISO8601DateFormatter()
                queryParams.append("end_date=\(formatter.string(from: end))")
            }
            queryParams.append("limit=100")

            let queryString = queryParams.isEmpty ? "" : "?\(queryParams.joined(separator: "&"))"
            let endpoint = "/api/v1/packs/\(packId)/activities\(queryString)"

            let response: [ActivityLogWithDetails] = try await APIClient.shared.request(endpoint)
            activities = response
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // Load activity types for the pack
    func loadActivityTypes(packId: Int) async {
        do {
            let response: [ActivityType] = try await APIClient.shared.request("/api/v1/packs/\(packId)/activity-types")
            activityTypes = response
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // Log a new activity
    func logActivity(packId: Int) async {
        guard let selectedType = selectedActivityType else {
            errorMessage = "Please select an activity type"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let request = CreateActivityLogRequest(
                activityTypeId: selectedType.id,
                notes: notes.isEmpty ? nil : notes,
                loggedAt: loggedAt
            )

            let _: ActivityLogWithDetails = try await APIClient.shared.request(
                "/api/v1/packs/\(packId)/activities",
                method: "POST",
                body: request
            )

            // Reset form
            selectedActivityType = nil
            notes = ""
            loggedAt = Date()

            // Reload activities
            await loadActivities(packId: packId)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // Quick log without notes
    func quickLog(packId: Int, activityType: ActivityType) async {
        selectedActivityType = activityType
        notes = ""
        loggedAt = Date()
        await logActivity(packId: packId)
    }
}
