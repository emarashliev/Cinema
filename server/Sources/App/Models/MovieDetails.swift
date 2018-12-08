import FluentMySQL
import Vapor

final class MovieDetails: Decodable {
    
    var id: Int?
    let title: String
    let homepage: String
    let language: String
    let overview: String
    let genres: [Genre]
    let actors: [Actor]

    init(movie: Movie, genres: [Genre], actors: [Actor]) {
        self.id = movie.id
        self.title = movie.title
        self.homepage = movie.homepage
        self.language = movie.language
        self.overview = movie.overview
        self.genres = genres
        self.actors = actors
    }
}

extension MovieDetails: Content {}

