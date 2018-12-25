import Vapor

struct ActorsController: RouteCollection {

    private let actorRepository: ActorRepository

    init(actorRepository: ActorRepository) {
        self.actorRepository = actorRepository
    }

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
        return try req.content.decode(Actor.self).flatMap { self.actorRepository.save(actor: $0) }

    }

    func getAllHandler(_ req: Request) throws -> Future<[Actor]> {
        return actorRepository.all()
    }

    func getHandler(_ req: Request) throws -> Future<Actor> {
        let actorId = try req.parameters.next(Actor.self)
        return try actorRepository.find(id: actorId)
    }

    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        let actorId = try req.parameters.next(Actor.self)
        return try actorRepository.delete(id: actorId)
    }
}
