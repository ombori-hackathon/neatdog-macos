import Foundation

actor APIClient {
    static let shared = APIClient()

    let baseURL = "http://localhost:8000/api/v1"
    private var token: String?

    func setToken(_ token: String?) {
        self.token = token
    }

    enum APIError: Error, LocalizedError {
        case invalidURL
        case invalidResponse
        case httpError(statusCode: Int, message: String?)
        case decodingError(Error)
        case networkError(Error)

        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Invalid URL"
            case .invalidResponse:
                return "Invalid response from server"
            case .httpError(let statusCode, let message):
                if let message = message {
                    return "HTTP \(statusCode): \(message)"
                }
                return "HTTP error \(statusCode)"
            case .decodingError(let error):
                return "Failed to decode response: \(error.localizedDescription)"
            case .networkError(let error):
                return "Network error: \(error.localizedDescription)"
            }
        }
    }

    private init() {}

    func request<T: Decodable>(
        _ endpoint: String,
        method: String = "GET",
        body: Encodable? = nil
    ) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Add auth header if token exists
        addAuthHeader(to: &request)

        // Add body if provided
        if let body = body {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            encoder.dateEncodingStrategy = .iso8601
            request.httpBody = try encoder.encode(body)
        }

        // Make request
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        // Check status code
        guard (200...299).contains(httpResponse.statusCode) else {
            // Try to decode error message
            let errorMessage = try? JSONDecoder().decode(ErrorResponse.self, from: data)
            throw APIError.httpError(
                statusCode: httpResponse.statusCode,
                message: errorMessage?.detail
            )
        }

        // Decode response
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            decoder.dateDecodingStrategy = .custom { decoder in
                let container = try decoder.singleValueContainer()
                let dateString = try container.decode(String.self)

                // Try ISO8601 with fractional seconds (API format: 2026-01-29T11:05:05.255266)
                let formatter = ISO8601DateFormatter()
                formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                if let date = formatter.date(from: dateString) {
                    return date
                }

                // Try without fractional seconds
                formatter.formatOptions = [.withInternetDateTime]
                if let date = formatter.date(from: dateString) {
                    return date
                }

                // Try with custom formatter for dates without timezone
                let customFormatter = DateFormatter()
                customFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
                customFormatter.timeZone = TimeZone(identifier: "UTC")
                if let date = customFormatter.date(from: dateString) {
                    return date
                }

                customFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                if let date = customFormatter.date(from: dateString) {
                    return date
                }

                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Cannot decode date: \(dateString)"
                )
            }
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }

    private func addAuthHeader(to request: inout URLRequest) {
        let logFile = "/tmp/neatdog-debug.log"
        let existing = (try? String(contentsOfFile: logFile)) ?? ""
        let msg = existing + "\n[APIClient] addAuthHeader - token is: \(self.token != nil ? "SET" : "nil")"
        try? msg.write(toFile: logFile, atomically: false, encoding: .utf8)
        if let token = self.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            let msg2 = msg + "\n[APIClient] Added Authorization header with token prefix: \(token.prefix(20))"
            try? msg2.write(toFile: logFile, atomically: false, encoding: .utf8)
        }
    }
}

// Error response model
private struct ErrorResponse: Codable {
    let detail: String
}
