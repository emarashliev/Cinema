import FluentSQLite
import Vapor

final class Actor: Codable {
    
    var id: Int?
    var name: String
}

extension Actor: SQLiteModel {}
extension Actor: Content {}
extension Actor: Migration {}
extension Actor: Parameter {}

extension Actor {
    var movies: Siblings<Actor, Movie, MovieActorPivot> {
        return siblings()
    }
}
