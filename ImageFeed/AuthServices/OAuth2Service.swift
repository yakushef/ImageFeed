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

final class OAuth2Service {
    
    static let shared = OAuth2Service()
    
    private let urlSession = URLSession.shared
    
    private var lastCode: String?
    private var task: URLSessionTask?
    
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
        
        assert(Thread.isMainThread)
        
        if lastCode == code { return }
        task?.cancel()
        lastCode = code

        let request = authTokenRequest(code: code)
        let task = object(for: request) { [weak self] result in
            guard let self = self else { return }
            assert(Thread.isMainThread)
            var taskError: Error?
            switch result {
            case .success(let body):
                let authToken = body.accessToken
                self.authToken = authToken
                completion(.success(authToken))
            case .failure(let error):
                taskError = error
                completion(.failure(error))
            }
            self.task = nil
            if taskError != nil {
                self.lastCode = nil
            }
        }
        self.task = task
        task.resume()
    }
    
    func authTokenRequest(code: String) -> URLRequest {

        let path = "/oauth/token" +
                   "?client_id=\(AccessKey)" +
                   "&&client_secret=\(SecretKey)" +
                   "&&redirect_uri=\(RedirectURI)" +
                   "&&code=\(code)" +
                   "&&grant_type=authorization_code"
        
        guard let url = URL(string: "https://unsplash.com") else { fatalError("Invalid base URL") }
                
        return URLRequest.makeHttpRequest(path: path,
                    httpMethod: "POST",
                    baseURL: url)
    }
}

extension OAuth2Service {
    private func object(for request: URLRequest,
                        completion: @escaping (Result<OAuthTokenResponseBody, Error>) -> Void) -> URLSessionTask {
        let decoder = JSONDecoder()
        return urlSession.data(for: request) { (result: Result<Data, Error>) in
            let response = result.flatMap { data -> Result<OAuthTokenResponseBody, Error> in
                Result {
                    try decoder.decode(OAuthTokenResponseBody.self, from: data)
                }
            }
            completion(response)
        }
    }
}
