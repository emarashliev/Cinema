@testable import App
import Vapor
import FluentMySQL

struct Helpers {
    
    static func getApiKey() throws -> String {
        guard let apiKey = Environment.get("API_KEY") else {
            throw Abort(.internalServerError, reason: "No $API_KEY set on environment. Use `export API_KEY=<secret>`")
        }
        return apiKey
    }

    static func resetDatabase(connection: MySQLConnection) throws {
        try Movie.query(on: connection).delete(force: true).wait()
        try Actor.query(on: connection).delete(force: true).wait()
        try Genre.query(on: connection).delete(force: true).wait()
        try MovieActorPivot.query(on: connection).delete(force: true).wait()
        try MovieGenrePivot.query(on: connection).delete(force: true).wait()
    }

    static func decodeResponse<T>(_ response: Response, to type: T.Type) throws -> T where T: Content {
        let jsonDecoder = JSONDecoder()
        let data = response.http.body.data
        return try jsonDecoder.decode(type, from: data!)
    }

    static func decodeJson<T>(_ jsonString: String, to type: T.Type) throws -> T where T: Content {
        let jsonDecoder = JSONDecoder()
        let data = jsonString.data(using: String.Encoding.utf8)
        return try jsonDecoder.decode(type, from: data!)
    }
}
