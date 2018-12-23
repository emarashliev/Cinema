import Vapor

public func setupRepositories(services: inout Services, config: inout Config) {
    services.register(MySQLMovieRepository.self)

    preferDatabaseRepositories(config: &config)
}

private func preferDatabaseRepositories(config: inout Config) {
    config.prefer(MySQLMovieRepository.self, for: MovieRepository.self)
}
