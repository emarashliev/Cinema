import Foundation
import Vapor
import FluentMySQL

final class MySQLMovieActorPivot: MySQLUUIDPivot {

    typealias Left = MySQLMovie
    typealias Right = MySQLActor
    
    static let leftIDKey: LeftIDKey = \.movieID
    static let rightIDKey: RightIDKey = \.actorID
    static var name: String { return "MovieActorPivot" }

    var id: UUID?
    var movieID: MySQLMovie.ID
    var actorID: MySQLActor.ID

    init(_ movieID: MySQLMovie.ID, _ actorID: MySQLActor.ID) {
        self.movieID = movieID
        self.actorID = actorID
    }
}

extension MySQLMovieActorPivot: Migration {
    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.movieID, to: \MySQLMovie.id, onDelete: .cascade)
            builder.reference(from: \.actorID, to: \MySQLActor.id, onDelete: .cascade)
        }
    }
}
