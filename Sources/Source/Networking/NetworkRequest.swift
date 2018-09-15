//
//  NetworkRequest.swift
//  SampleProject
//
//  Created by Kirby on 6/19/17.
//  Copyright © 2017 Kirby. All rights reserved.

import Foundation

public enum HTTPMethod: String {
    case get
    
    var name: String {
        return rawValue.uppercased()
    }
}

// handles the request to get data
public protocol NetworkRequest {
    var baseURL: URL? { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: [String: Any]? { get }
}

public extension NetworkRequest {
    
    func buildURLRequest() -> URLRequest? {
        
        guard let baseURL = baseURL else {
            return nil
        }
        
        let url = baseURL.appendingPathComponent(path)
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        
        switch method {
        case .get:
            let dictionary = parameters
            let queryItems = dictionary?.map { key, value in
                return URLQueryItem(name: key, value: String(describing: value))
            }
            components?.queryItems = queryItems
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.url = components?.url
        urlRequest.httpMethod = method.name
        
        return urlRequest
    }
    
    func response(from data: Data, urlResponse: HTTPURLResponse) -> Response {
        return Response(statusCode: urlResponse.statusCode, data: data)
    }
}
