import Vapor

public func setupRepositories(services: inout Services, config: inout Config) {
    /// Register providers first
    services.register(MySQLMovieRepository.self)
    services.register(MySQLGenreRepository.self)
    services.register(MySQLActorRepository.self)

    preferDatabaseRepositories(config: &config)
}

private func preferDatabaseRepositories(config: inout Config) {
    config.prefer(MySQLMovieRepository.self, for: MovieRepository.self)
    config.prefer(MySQLGenreRepository.self, for: GenreRepository.self)
    config.prefer(MySQLActorRepository.self, for: ActorRepository.self)
}
