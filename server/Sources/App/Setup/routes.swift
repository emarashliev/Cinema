import Routing
import Vapor

/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)
public func routes(_ router: Router, container: Container) throws {
    let movieRepo = try container.make(MovieRepository.self)
    try router.register(collection: MoviesController(movieRepository: movieRepo))
    let genreRepo = try container.make(GenreRepository.self)
    try router.register(collection: GenresController(genreRepository: genreRepo))
    let actorRepo = try container.make(ActorRepository.self)
    try router.register(collection: ActorsController(actorRepository: actorRepo))
}
