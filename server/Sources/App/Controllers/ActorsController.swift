import Vapor

struct ActorsController: RouteCollection {

    func boot(router: Router) throws {
        let actorsRoute = router.grouped("api", "actors")
        actorsRoute.post(use: createHandler)
        actorsRoute.get(use: getAllHandler)
        actorsRoute.get(Actor.parameter, use: getHandler)
        actorsRoute.get(Actor.parameter, "movies", use: getMoviesHandler)
    }

    func createHandler(_ req: Request) throws -> Future<Actor> {
        let аctor = try req.content.decode(Actor.self)
        return аctor.save(on: req)
    }

    func getAllHandler(_ req: Request) throws -> Future<[Actor]> {
        return Actor.query(on: req).all()
    }

    func getHandler(_ req: Request) throws -> Future<Actor> {
        return try req.parameters.next(Actor.self)
    }

    func getMoviesHandler(_ req: Request) throws -> Future<[Movie]> {
        return try req.parameters.next(Actor.self).flatMap(to: [Movie].self) { actors in
            return try actors.movies.query(on: req).all()
        }
    }

}
