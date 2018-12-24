import Vapor
import FluentMySQL

protocol ActorRepository: ServiceType {

    func save(actor: Actor) -> Future<Actor>
    func delete(id: Int) throws -> Future<HTTPStatus>
    func all() -> Future<[Actor]>
    func find(id: Int) throws -> Future<Actor>
}

final class MySQLActorRepository: ActorRepository {
    
    let db: MySQLDatabase.ConnectionPool

    init(_ db: MySQLDatabase.ConnectionPool) {
        self.db = db
    }

    func save(actor: Actor) -> Future<Actor> {
        return db.withConnection { conn in
            return MySQLActor(id: actor.id, name: actor.name)
                .save(on: conn)
                .map(to: Actor.self) { Actor(id: $0.id, name: $0.name) }
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

    func all() -> Future<[Actor]> {
        return db.withSQLConnection { conn in
            MySQLActor.query(on: conn)
                .all()
                .map { $0.map { Actor(id: $0.id, name: $0.name) } }
        }
    }

    func find(id: Int) throws -> Future<Actor> {
        return db.requestConnection().flatMap { conn in
            try self.find(id: id, conn: conn)
                .map { Actor(id: $0.id, name: $0.name) }
        }
    }

    private func find(id: Int, conn: MySQLConnection) throws -> Future<MySQLActor> {
        return MySQLActor.find(id, on: conn)
            .unwrap(or: Abort(.notFound, reason: "Not found Actor with id \(id)"))
    }

}

//MARK: - ServiceType conformance
extension MySQLActorRepository {
    static let serviceSupports: [Any.Type] = [ActorRepository.self]

    static func makeService(for worker: Container) throws -> Self {
        return .init(try worker.connectionPool(to: .mysql))
    }
}
