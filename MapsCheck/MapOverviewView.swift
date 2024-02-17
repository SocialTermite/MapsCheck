//
//  ContentView.swift
//  MapsCheck
//
//  Created by Konstantin Bondar on 17.02.2024.
//

import SwiftUI
import MapKit

class MapOverviewViewModel: ObservableObject {
    private let apiClient = APIClient()
    
    @Published var cars: [Car] = []
    @Published var reservedCar: Car?
    
    func loadCars() {
        apiClient.getCars { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let cars):
                    self?.cars = cars
                    self?.reservedCar = cars[0]
                case .failure(let failure):
                    print(failure)
                }
            }
        }
    }
    
    func reserve(_ car: Car?) {
        reservedCar = car
    }
    
    func isReserved(car: Car) -> Bool {
        return reservedCar == car
    }
    
    func calculateAveragePosition() -> CLLocationCoordinate2D {
        guard !cars.isEmpty else {
            return CLLocationCoordinate2D(latitude: 0, longitude: 0)
        }
        
        let sumLatitude = cars.map { $0.position.latitude }.reduce(0, +)
        let sumLongitude = cars.map { $0.position.longitude }.reduce(0, +)
        
        let averageLatitude = sumLatitude / Double(cars.count)
        let averageLongitude = sumLongitude / Double(cars.count)
        
        return CLLocationCoordinate2D(latitude: averageLatitude, longitude: averageLongitude)
    }
}

struct MapOverviewView: View {
    @State var region = MKCoordinateRegion(
        center: .init(latitude: 48.137154,longitude: 11.576124),
        span: .init(latitudeDelta: 0.06, longitudeDelta: 0.06)
    )
    
    @State var selectedCar: Car?
    @State var selectedCarDistance: String?
    @State var selectedCarTime: String?
    @State var isDetailsShown: Bool = false
    private var locationManager = CLLocationManager()
    
    @ObservedObject private var viewModel: MapOverviewViewModel = .init()
    var body: some View {
        ZStack {
            map
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        // Center the map on the user's location when the button is tapped
                        
                        if let userLocation = locationManager.location?.coordinate {
                            region = MKCoordinateRegion(center: userLocation, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 50, height: 50)
                            
                            Image(systemName: "location.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .foregroundColor(.white)
                                .frame(width: 20, height: 20)
                        }
                    }
                    .padding()
                    .padding(.bottom, 50)
                }
            }
            
            if let selectedCar, isDetailsShown {
                VStack {
                    Spacer()
                    CarDetailsView(isShown: $isDetailsShown, isReserved: .init(get: {
                            return viewModel.isReserved(car: selectedCar)
                    }, set: { isReserved in
                        viewModel.reserve(isReserved ? selectedCar : nil)
                    }), car: selectedCar)
                }
            }
            
        }
        .onAppear {
            viewModel.loadCars()
        }
    }
    
    @ViewBuilder
    var map: some View {
        Map(
            coordinateRegion: $region,
            showsUserLocation: true,
            userTrackingMode: .constant(.none),
            annotationItems: viewModel.cars
        ) { car in
            MapAnnotation(coordinate: car.position) {
                if let url = URL(string: car.carImageUrl) {
                    CarMarkerView(carImageUrl: url,
                                  isReserved: viewModel.isReserved(car: car),
                                  time: $selectedCarTime,
                                  distance: $selectedCarDistance,
                                  isSelected: .init(get: {
                        car == selectedCar
                    }, set: { isSelected in
                        if isSelected {
                            if let userLocation = locationManager.location {
                                calculateDistance(userLocation: userLocation.coordinate,
                                                  carLocation: car.position) {
                                    selectedCar = car
                                    isDetailsShown = true
                                }
                            }
                            
                        } else {
                            isDetailsShown = false
                            selectedCar = nil
                        }
                    })
                    )
                }
            }
        }
        .onAppear {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    private func calculateDistance(userLocation: CLLocationCoordinate2D, carLocation: CLLocationCoordinate2D, completion: @escaping () -> Void) {
            selectedCarDistance = nil
            selectedCarTime = nil
            let sourcePlacemark = MKPlacemark(coordinate: userLocation)
            let destinationPlacemark = MKPlacemark(coordinate: carLocation)

            let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
            let destinationMapItem = MKMapItem(placemark: destinationPlacemark)

            let directionRequest = MKDirections.Request()
            directionRequest.source = sourceMapItem
            directionRequest.destination = destinationMapItem
            directionRequest.transportType = .walking

            let directions = MKDirections(request: directionRequest)
            directions.calculate { (response, error) in
                guard let response = response, let route = response.routes.first else {
                    // Handle error
                    return
                }

                let distanceInMeters = route.distance
                let distanceInKilometers = Measurement(value: distanceInMeters, unit: UnitLength.meters).converted(to: .kilometers).value
                let formattedDistance = String(format: "%.2f", distanceInKilometers)
                print("Walking distance: \(formattedDistance) km")
                selectedCarDistance = "\(formattedDistance) km"

                let travelTimeInSeconds = route.expectedTravelTime
                let travelTimeInMinutes = Int(travelTimeInSeconds / 60)
                print("Estimated walking time: \(travelTimeInMinutes) minutes")
                selectedCarTime = "\(travelTimeInMinutes) minutes"
                
                completion()
            }
        }
}


#Preview {
    MapOverviewView()
}
