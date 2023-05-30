//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Aleksey Yakushev on 28.05.2023.
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
                                baseURL: URL = DefaultBaseURL) -> URLRequest {
        var request = URLRequest(url: URL(string: path, relativeTo: baseURL)!)
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

final class OAuth2Service {
    
    static let shared = OAuth2Service()
    
    private let urlSession = URLSession.shared
    
    private (set) var authToken: String? {
        get {
            return OAuth2TokenStorage().token
        }
        set {
            OAuth2TokenStorage().token = newValue
        }
    }
    
    func fetchAuthToken(code: String,
                        completion: @escaping (Result<String, Error>) -> Void) {

        let request = authTokenRequest(code: code)
        
        let task = object(for: request) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let body):
                let authToken = body.accessToken
                self.authToken = authToken
                completion(.success(authToken))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    func authTokenRequest(code: String) -> URLRequest {
//        var urlComponents = URLComponents()
//        urlComponents.scheme = "https"
//        urlComponents.host = "unsplash.com"
//        urlComponents.path = "/oauth/token"
//
//        urlComponents.queryItems = [URLQueryItem(name: "client_id", value: AccessKey),
//        URLQueryItem(name: "client_secret", value: SecretKey),
//        URLQueryItem(name: "redirect_uri", value: RedirectURI),
//        URLQueryItem(name: "code", value: code),
//        URLQueryItem(name: "grant_type", value: "authorization_code")]
//
//        return URLRequest.makeHttpRequest(path: urlComponents.path, httpMethod: "POST")
        
        let path = "/oauth/token" + "?client_id=\(AccessKey)" + "&&client_secret=\(SecretKey)" + "&&redirect_uri=\(RedirectURI)" + "&&code=\(code)" + "&&grant_type=authorization_code"
        return URLRequest.makeHttpRequest(path: path,
                    httpMethod: "POST",
                    baseURL: URL(string: "https://unsplash.com")!
        )
    }
    
//    func object(for request: URLRequest,
//                completion: @escaping (Result<OAuthTokenResponseBody, Error>) -> Void) -> URLSessionTask {
//        let decoder = JSONDecoder()
//        return urlSession.data(for: request) { (result: Result<Data, Error>) in
//            let response = result.flatMap { data -> Result<OAuthTokenResponseBody, Error> in
//                Result { try decoder.decode(OAuthTokenResponseBody.self, from: data) }
//            }
//           completion(response)
//        }
//
//    }
    
    
    func authorizeUsingToken() {
        
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.unsplash.com"
        urlComponents.path = "/me"
        var url = urlComponents.url!
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        
        let authToken = OAuth2TokenStorage().token
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        
        struct User: Encodable {
            let username: String
        }
        request.httpBody = try? JSONEncoder().encode(User(username: "Test"))
    }
    
}

//TODO: flatMap
extension OAuth2Service {
    private func object(for request: URLRequest,
                        completion: @escaping (Result<OAuthTokenResponseBody, Error>) -> Void) -> URLSessionTask {
        let decoder = JSONDecoder()
        return urlSession.data(for: request) { (result: Result<Data, Error>) in
            switch result {
            case .success(let data):
                do {
                    let object = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                    completion(.success(object))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
