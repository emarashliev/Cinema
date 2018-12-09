@testable import App
import Vapor
import FluentMySQL
import XCTest

final class MovieTests: XCTestCase {

    var connection: MySQLConnection!
    var app: Application!
    let moviesURI = "api/movies/"

    override func setUp() {
        app = try! Application.setup()
        connection = try! app.newConnection(to: .mysql).wait()
        try! Helpers.resetDatabase(connection: connection)
    }

    override func tearDown() {
        connection.close()
    }

    // Mark: Test cases
    func testMoviesCanBeRetrievedFromAPI() throws {
        let expectedTitle = "Mr. Robot"
        let expectedOverview = "crazy hacker"

        //Given
        let movie = try createAndSaveMovie(title: expectedTitle, overview: expectedOverview)
        _ = try createAndSaveMovie(title: "Preacher", overview: "crazy priest")

        //When
        let response = try app.getRequest(to: moviesURI)
        let movies = try Helpers.decodeResponse(response, to: [Movie].self)

        //Then
        XCTAssertEqual(movies.count, 2)
        XCTAssertEqual(movies.first?.title, expectedTitle)
        XCTAssertEqual(movies.first?.overview, expectedOverview)
        XCTAssertEqual(movies.first?.id, movie.id)

    }

    func testCanFindMovieByKeyword() throws {
        let expectedTitle = "Mr. Robot"
        let keyword = "hacker"

        //Given
        let movie = try createAndSaveMovie(title: "Mr. Robot", overview: "crazy hacker")
        _ = try createAndSaveMovie(title: "Preacher", overview: "crazy priest")


        //When
        let searchQuery = URLQueryItem(name: "searchQuery", value: keyword)
        let response = try app.getRequest(to: moviesURI, queryItems: [searchQuery])
        let movies = try Helpers.decodeResponse(response, to: [Movie].self)

        //Then
        XCTAssertEqual(movies.count, 1)
        XCTAssertEqual(movies.first?.title, expectedTitle)
        XCTAssertEqual(movies.first?.id, movie.id)
    }

    func testCanFindAllMoviesWithKeyword() throws {
        let keyword = "crazy"

        //Given
        _ = try createAndSaveMovie(title: "Mr. Robot", overview: "crazy hacker")
        _ = try createAndSaveMovie(title: "Preacher", overview: "crazy priest")

        //When
        let searchQuery = URLQueryItem(name: "searchQuery", value: keyword)
        let response = try app.getRequest(to: moviesURI, queryItems: [searchQuery])
        let movies = try Helpers.decodeResponse(response, to: [Movie].self)

        //Then
        XCTAssertEqual(movies.count, 2)
    }


    func testCanFindAMovieByTitle() throws {
        let expectedTitle = "Mr. Robot"

        //Given
        let movie = try createAndSaveMovie(title: expectedTitle, overview: "crazy hacker")
        _ = try createAndSaveMovie(title: "Preacher", overview: "crazy priest")


        //When
        let searchQuery = URLQueryItem(name: "searchQuery", value: expectedTitle)
        let response = try app.getRequest(to: moviesURI, queryItems: [searchQuery])
        let movies = try Helpers.decodeResponse(response, to: [Movie].self)

        //Then
        XCTAssertEqual(movies.count, 1)
        XCTAssertEqual(movies.first?.title, expectedTitle)
        XCTAssertEqual(movies.first?.id, movie.id)
    }

    func testCreateAMovie()  throws {
        let expectedTitle = "Mr. Robot"
        let expectedOverview = "crazy hacker"

        //When
        let movie = try createMovie(title: expectedTitle, overview: expectedOverview)
        let response = try app.sendRequest(to: moviesURI,
                                        method: .POST,
                                        headers: ["Content-Type": "application/json"],
                                        body: movie)

        let movieFromResponse = try Helpers.decodeResponse(response, to: Movie.self)

        //Then
        XCTAssertEqual(response.http.status, .ok)
        XCTAssertEqual(movieFromResponse.title, expectedTitle)
        XCTAssertEqual(movieFromResponse.overview, expectedOverview)
    }

}

// Mark: Helpers
extension MovieTests {
    func createAndSaveMovie(title: String, overview: String) throws -> Movie {
        let movie = try createMovie(title: title, overview: overview)
        return try movie.save(on: connection).wait()
    }

    func createMovie(title: String, overview: String) throws -> Movie {
        let jsonString = """
            {
            "title" : "",
            "homepage" : "",
            "language" : "",
            "overview" : ""
            }
        """
        let movie = try Helpers.decodeJson(jsonString, to: Movie.self)
        movie.title = title
        movie.overview = overview
        return movie
    }
}
