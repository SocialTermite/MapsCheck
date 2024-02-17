//
//  APIClient.swift
//  MapsCheck
//
//  Created by Konstantin Bondar on 17.02.2024.
//

import Foundation
import MapKit

//https://app.check24.de/cars.json
//
//{
//  "id": "id0",
//  "modelId": "mini",
//  "modelName": "MINI",
//  "name": "Car1",
//  "brand": "BMW",
//  "group": "MINI",
//  "series": "MINI",
//  "fuelType": "D",
//  "fuelLevel": 0.7,
//  "transmission": "M",
//  "licensePlate": "M-AA1234",
//  "latitude": "48.134557",
//  "longitude": "11.576921",
//  "innerCleanliness": "REGULAR",
//  "carImageUrl": "https://app.check24.de/img/purple.webp"
//}

struct Car: Decodable, Identifiable, Equatable {
    var id: String
    var name: String
    var brand: String
    var fuelType: String
    var transmission: String
    var modelName: String
    private var latitude: String
    private var longitude: String
    var carImageUrl: String
    
    var position: CLLocationCoordinate2D {
        .init(latitude: Double(latitude) ?? 0, longitude: Double(longitude) ?? 0)
    }
}

enum Constants {
    enum API {
        static let host: String = "https://app.check24.de/"
    }
}

class RequestProvider {
    func carsRequest() -> URLRequest {
        let url = URL(string: "\(Constants.API.host)cars.json")!
        
        return .init(url: url)
    }
}

protocol Webservice {
    func dataTask<T: Decodable>(urlRequest: URLRequest, type: T.Type, completion: @escaping (Result<T, APIClientError>) -> Void)
}

enum APIClientError: Error {
    case badRequest
    case notFound
    case customError(Error)
}


class CarsWebservice: Webservice {
    func dataTask<T: Decodable>(urlRequest: URLRequest, type: T.Type, completion: @escaping (Result<T, APIClientError>) -> Void) {
        let task = URLSession.shared.dataTask(with: urlRequest) { data, _, error in
            if let error {
                return completion(.failure(.customError(error)))
            }
            
            guard let data else {
                return completion(.failure(.notFound))
            }
            
            do {
                let model = try JSONDecoder().decode(T.self, from: data)
                completion(.success(model))
            } catch {
                completion(.failure(.customError(error)))
            }
        }
        
        task.resume()
    }
}

class APIClient {
    private let webservice: Webservice
    private let requestProvider: RequestProvider = .init()
    
    init(webservice: Webservice = CarsWebservice()) {
        self.webservice = webservice
    }
    
    func getCars(completion: @escaping (Result<[Car], APIClientError>) -> Void) {
        let request = requestProvider.carsRequest()
        
        webservice.dataTask(urlRequest: request, type: [Car].self) { result in
            switch result {
            case .success(let cars):
                completion(.success(cars))
            case .failure(let failure):
                completion(.failure(failure))
            }
        }
    }
    
}
