import Vapor
import FluentMySQL

protocol GenreRepository: ServiceType {

    func save(genre: Genre) -> Future<Genre>
    func delete(id: Int) throws -> Future<HTTPStatus>
    func all() -> Future<[Genre]>
    func find(id: Int) throws -> Future<Genre>
}

final class MySQLGenreRepository: GenreRepository {
    
    let db: MySQLDatabase.ConnectionPool

    init(_ db: MySQLDatabase.ConnectionPool) {
        self.db = db
    }

    func save(genre: Genre) -> Future<Genre> {
        return db.withConnection { conn in
            return MySQLGenre(id: genre.id, name: genre.name)
                .save(on: conn)
                .map(to: Genre.self) { Genre(id: $0.id, name: $0.name) }
        }
    }

    func delete(id: Int) throws -> Future<HTTPStatus> {
        return db.requestConnection().flatMap { conn in
            return try self.find(id: id, conn: conn)
                .flatMap(to: HTTPStatus.self) { movie in
                    return movie.delete(on: conn).transform(to: HTTPStatus.noContent)
            }
        }
    }

    func all() -> Future<[Genre]> {
        return db.withSQLConnection { conn in
            MySQLGenre.query(on: conn)
                .all()
                .map { $0.map { Genre(id: $0.id, name: $0.name) } }
        }
    }

    func find(id: Int) throws -> Future<Genre> {
        return db.requestConnection().flatMap { conn in
            try self.find(id: id, conn: conn)
                .map { Genre(id: $0.id, name: $0.name) }
        }
    }

    private func find(id: Int, conn: MySQLConnection) throws -> Future<MySQLGenre> {
        return MySQLGenre.find(id, on: conn)
            .unwrap(or: Abort(.notFound, reason: "Not found Genre with id \(id)"))
    }

}

//MARK: - ServiceType conformance
extension MySQLGenreRepository {
    static let serviceSupports: [Any.Type] = [GenreRepository.self]

    static func makeService(for worker: Container) throws -> Self {
        return .init(try worker.connectionPool(to: .mysql))
    }
}
