import Vapor

struct GenresController: RouteCollection, RestfulController {

    typealias Model = Genre
    
    func boot(router: Router) throws {
        let genresRoute = router.grouped("api", "genres")
        genresRoute.post(use: createHandler)
        genresRoute.get(use: getAllHandler)
        genresRoute.get(Genre.parameter, use: getHandler)
        genresRoute.get(Genre.parameter, "movies", use: getMoviesHandler)
    }


    func getMoviesHandler(_ req: Request) throws -> Future<[Movie]> {
        return try req.parameters.next(Genre.self).flatMap(to: [Movie].self) { genre in
            return try genre.movies.query(on: req).all()
        }
    }
}
