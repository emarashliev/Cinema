import FluentMySQL
import Vapor
import Foundation
//
//final class MovieActorPivot: MySQLUUIDPivot {
//    
//    var id: UUID?
//    var movieID: Movie.ID
//    var actorID: Actor.ID
//
//    typealias Left = Movie
//    typealias Right = Actor
//    static let leftIDKey: LeftIDKey = \.movieID
//    static let rightIDKey: RightIDKey = \.actorID
//
//    init(_ movieID: Movie.ID, _ actorID: Actor.ID) {
//        self.movieID = movieID
//        self.actorID = actorID
//    }
//}
//
//extension MovieActorPivot: Migration {
//    static func prepare(on connection: MySQLConnection) -> Future<Void> {
//        return Database.create(self, on: connection) { builder in
//            try addProperties(to: builder)
//            builder.reference(from: \.movieID, to: \Movie.id, onDelete: .cascade)
//            builder.reference(from: \.actorID, to: \Actor.id, onDelete: .cascade)
//        }
//    }
//}
