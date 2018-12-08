import Vapor

final class ApiMiddleware: Middleware {

    let apiKey: String

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    func respond(to request: Request, chainingTo next: Responder) throws -> Future<Response> {
        guard request.query[String.self, at: "apiKey"] == apiKey else {
            throw Abort(.unauthorized, reason: "Incorrect apiKey.")
        }

        return try next.respond(to: request)
    }
}

extension ApiMiddleware: ServiceType {

    static func makeService(for worker: Container) throws -> ApiMiddleware {
        guard let apiKey = Environment.get("API_KEY") else {
            throw Abort(.internalServerError, reason: "No $API_KEY set on environment. Use `export API_KEY=<secret>`")
        }
        return ApiMiddleware(apiKey: apiKey)
    }
}
