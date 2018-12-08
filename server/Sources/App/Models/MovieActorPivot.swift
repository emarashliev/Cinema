import FluentMySQL
import Vapor
import Foundation

final class MovieActorPivot: MySQLUUIDPivot {
    
    var id: UUID?
    var movieID: Movie.ID
    var actorID: Actor.ID

    typealias Left = Movie
    typealias Right = Actor
    static let leftIDKey: LeftIDKey = \MovieActorPivot.movieID
    static let rightIDKey: RightIDKey = \MovieActorPivot.actorID

    init(_ movieID: Movie.ID, _ actorID: Actor.ID) {
        self.movieID = movieID
        self.actorID = actorID
    }
}

extension MovieActorPivot: Migration {}
