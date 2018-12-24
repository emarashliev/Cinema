import Vapor

struct ActorsController: RouteCollection {

    func boot(router: Router) throws {
        let actorsRoute = router.grouped("api", "actors")
        actorsRoute.post(use: createHandler)
        actorsRoute.get(use: getAllHandler)
        actorsRoute.get(Actor.parameter, use: getHandler)
        actorsRoute.delete(Actor.parameter, use: deleteHandler)

    }
}

// MARK: - Actor handlers

extension ActorsController {
    func createHandler(_ req: Request) throws -> Future<Actor> {
        let repository = try req.make(ActorRepository.self)
        return try req.content.decode(Actor.self).flatMap { repository.save(actor: $0) }

    }

    func getAllHandler(_ req: Request) throws -> Future<[Actor]> {
        let repository = try req.make(ActorRepository.self)
        return repository.all()
    }

    func getHandler(_ req: Request) throws -> Future<Actor> {
        let repository = try req.make(ActorRepository.self)
        let actorId = try req.parameters.next(Actor.self)
        return try repository.find(id: actorId)
    }

    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        let repository = try req.make(ActorRepository.self)
        let actorId = try req.parameters.next(Actor.self)
        return try repository.delete(id: actorId)
    }
}
