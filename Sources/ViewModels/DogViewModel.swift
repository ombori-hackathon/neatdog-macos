import Foundation
import Observation

@Observable
@MainActor
class DogViewModel {
    var dog: Dog?
    var activityTypes: [ActivityType] = []
    var isLoading = false
    var errorMessage: String?

    // Form state for creating/editing dog
    var dogName = ""
    var dogBreed = ""
    var dogBirthDate: Date?
    var hasDog = false

    // Custom activity type form
    var customTypeName = ""
    var customTypeIcon = "pawprint.fill"
    var customTypeColor = "#3B82F6"

    func loadDog(packId: Int) async {
        isLoading = true
        errorMessage = nil

        do {
            dog = try await APIClient.shared.request("/api/v1/packs/\(packId)/dog")
            hasDog = true

            // Populate form with existing data
            if let dog = dog {
                dogName = dog.name
                dogBreed = dog.breed ?? ""
                dogBirthDate = dog.birthDate
            }

            isLoading = false
        } catch let error as APIClient.APIError {
            // If it's a 404, the pack doesn't have a dog yet
            if case .httpError(let statusCode, _) = error, statusCode == 404 {
                hasDog = false
                dog = nil
            } else {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    func createDog(packId: Int) async {
        guard !dogName.isEmpty else {
            errorMessage = "Dog name cannot be empty"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let request = CreateDogRequest(
                name: dogName,
                breed: dogBreed.isEmpty ? nil : dogBreed,
                birthDate: dogBirthDate,
                photoUrl: nil
            )

            dog = try await APIClient.shared.request(
                "/api/v1/packs/\(packId)/dog",
                method: "POST",
                body: request
            )

            hasDog = true
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    func updateDog(packId: Int) async {
        guard !dogName.isEmpty else {
            errorMessage = "Dog name cannot be empty"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let request = UpdateDogRequest(
                name: dogName,
                breed: dogBreed.isEmpty ? nil : dogBreed,
                birthDate: dogBirthDate,
                photoUrl: nil
            )

            dog = try await APIClient.shared.request(
                "/api/v1/packs/\(packId)/dog",
                method: "PATCH",
                body: request
            )

            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    func loadActivityTypes(packId: Int) async {
        isLoading = true
        errorMessage = nil

        do {
            activityTypes = try await APIClient.shared.request("/api/v1/packs/\(packId)/activity-types")
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    func createCustomActivityType(packId: Int) async {
        guard !customTypeName.isEmpty else {
            errorMessage = "Activity type name cannot be empty"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let request = CreateActivityTypeRequest(
                name: customTypeName,
                icon: customTypeIcon,
                color: customTypeColor
            )

            let newType: ActivityType = try await APIClient.shared.request(
                "/api/v1/packs/\(packId)/activity-types",
                method: "POST",
                body: request
            )

            activityTypes.append(newType)

            // Clear form
            customTypeName = ""
            customTypeIcon = "pawprint.fill"
            customTypeColor = "#3B82F6"

            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
}
