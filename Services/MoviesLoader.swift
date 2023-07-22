//
//  MoviesLoader.swift
//  MovieQuiz
//
//  Created by Irina Golubinskaya on 05.07.2023.
//
///В этом файле мы и создадим сервис для загрузки фильмов. Он будет :
///1.загружать фильмы, используя NetworkClient
///2.преобразовывать их в модель данных MostPopularMovies.
///
import Foundation

protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}

struct MoviesLoader: MoviesLoading {
    
    private let netWorkClient: NetWorkRouting
    
    init(netWorkClient: NetWorkRouting = NetWorkClient()) {
        self.netWorkClient = netWorkClient
    }
    
    // MARK : - URL
    private var mostPopularMoviesUrl : URL {
        guard let url = URL(string: "https://imdb-api.com/en/API/Top250Movies/k_zcuw1ytf") else {
            preconditionFailure("Unable to construct mostPopularMoviesUrl")
        }
        return url
    }
    
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>)-> Void) {
        netWorkClient.fetch(url: mostPopularMoviesUrl, handler:  { result in
            switch result {
            case .success(let data):
                do {
                    let mostPopularMovies = try JSONDecoder().decode(MostPopularMovies.self, from: data)
                    handler(.success(mostPopularMovies))
                } catch {
                    handler(.failure(error))
                }
            case .failure(let error):
                handler(.failure(error))
            }
        })
    }
}


