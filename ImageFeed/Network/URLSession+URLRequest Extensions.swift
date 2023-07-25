//
//  URLSession Extensions.swift
//  ImageFeed
//
//  Created by Aleksey Yakushev on 18.06.2023.
//

import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
}

extension URLRequest {
    static func makeHttpRequest(path: String,
                                httpMethod: String,
                                baseURL: URL = AuthConfiguration.standard.baseURL) -> URLRequest {
        
        let url: URL = {
            guard let url = URL(string: path, relativeTo: baseURL) else {
                assertionFailure("Invalid DefaultBaseURL")
                return URL(string: "")!
            }
            return url
        }()
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        return request
    }
}

extension URLSession {
    func data(for request: URLRequest,
              comletion: @escaping (Result<Data, Error>) -> Void) -> URLSessionTask {
        let fullfillCompletion: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                comletion(result)
            }
        }
        
        let task = dataTask(with: request) { data, response, error in
            if let data = data,
               let response = response,
               let statusCode = (response as? HTTPURLResponse)?.statusCode
            {
                if 200..<300 ~= statusCode {
                    fullfillCompletion(.success(data))
                } else {
                    fullfillCompletion(.failure(NetworkError.httpStatusCode(statusCode)))
                }
            }
            else if let error = error {
                fullfillCompletion(.failure(NetworkError.urlRequestError(error)))
            } else {
                fullfillCompletion(.failure(NetworkError.urlSessionError))
            }
        }
        task.resume()
        return task
    }
}


// MARK: -Object Task

extension URLSession {
    func objectTask<T: Decodable>(for request: URLRequest,
                                  completion: @escaping (Result<T, Error>) -> Void) -> URLSessionTask {
        let fulfillCompletionOnMainThread: (Result<T, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        let task = dataTask(with: request, completionHandler: { data, response, error in
            if let data = data,
               let response = response,
               let statusCode = (response as? HTTPURLResponse)?.statusCode {
                
                if 200 ..< 300 ~= statusCode {
                    do {
                        let decoder = JSONDecoder()
                        let result = try decoder.decode(T.self, from: data)
                        fulfillCompletionOnMainThread(.success(result))
                    } catch {
                        fulfillCompletionOnMainThread(.failure(error))
                    }
                } else {
                    fulfillCompletionOnMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                }
            } else if let error = error {
                fulfillCompletionOnMainThread(.failure(error))
            } else {
                fulfillCompletionOnMainThread(.failure(NetworkError.urlSessionError))
            }
        })
        return task
    }
}
