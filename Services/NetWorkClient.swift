//
//  NetWorkClient.swift
//  MovieQuiz
//
//  Created by Irina Golubinskaya on 04.07.2023.
//

import Foundation

struct NetWorkClient {
    
    private enum NetWorkEnum: Error {
        case codeError
    }
    
    public enum Result <Success, Failure> where Failure : Error {
        case success(Success)
        case failure(Failure)
    }
    
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void ) {
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error  in
            if let error = error {
                handler(.failure(error))
                return
            }
            
            if let response = response as? HTTPURLResponse,
               response.statusCode < 200 || response.statusCode >= 300 {
                handler(.failure(NetWorkEnum.codeError))
                return
            }
            
            guard let data = data else { return }
            handler(.success(data))
        }
        task.resume()
    }
}