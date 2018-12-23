import Vapor

//struct ActorsController: RouteCollection, RestfulController {
//
//    typealias Model = Actor
//
//    func boot(router: Router) throws {
//        let actorsRoute = router.grouped("api", "actors")
//        actorsRoute.post(use: createHandler)
//        actorsRoute.get(use: getAllHandler)
//        actorsRoute.get(Actor.parameter, use: getHandler)
//        actorsRoute.get(Actor.parameter, "movies", use: getMoviesHandler)
//    }
//
//    func getMoviesHandler(_ req: Request) throws -> Future<[Movie]> {
//        return try req.parameters.next(Actor.self).flatMap(to: [Movie].self) { actors in
//            return try actors.movies.query(on: req).all()
//        }
//    }
//
//}
