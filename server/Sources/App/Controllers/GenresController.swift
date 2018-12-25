import Vapor

struct GenresController: RouteCollection {

    private let genreRepository: GenreRepository

    init(genreRepository: GenreRepository) {
        self.genreRepository = genreRepository
    }

    func boot(router: Router) throws {
        let genresRoute = router.grouped("api", "genres")
        genresRoute.post(use: createHandler)
        genresRoute.get(use: getAllHandler)
        genresRoute.get(Genre.parameter, use: getHandler)
        genresRoute.delete(Genre.parameter, use: deleteHandler)

    }
}

// MARK: - Genre handlers

extension GenresController {
    func createHandler(_ req: Request) throws -> Future<Genre> {
        return try req.content.decode(Genre.self).flatMap { self.genreRepository.save(genre: $0) }
    }

    func getAllHandler(_ req: Request) throws -> Future<[Genre]> {
        return genreRepository.all()
    }

    func getHandler(_ req: Request) throws -> Future<Genre> {
        let genreId = try req.parameters.next(Genre.self)
        return try genreRepository.find(id: genreId)
    }

    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        let genreId = try req.parameters.next(Genre.self)
        return try genreRepository.delete(id: genreId)
    }
}
