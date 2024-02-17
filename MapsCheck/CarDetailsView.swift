//
//  CarDetailsView.swift
//  MapsCheck
//
//  Created by Konstantin Bondar on 17.02.2024.
//

import SwiftUI

struct CarDetailsView: View {
    @Binding var isShown: Bool
    @Binding var isReserved: Bool
    var car: Car
    
    var body: some View {
        VStack {
            Spacer() // Add space at the top
            VStack {
                Button {
                    isShown.toggle()
                } label: {
                    Image(systemName: "arrow.down")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 30)
                }

                Image(systemName: "car")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150)
                HStack {
                    VStack(alignment: .leading) {
                        Text(car.name)
                            .font(.system(size: 20, weight: .bold))
                        HStack {
                            Text(car.brand)
                                .font(.system(size: 20))
                            Text("|")
                                .font(.system(size: 20))
                            Text(car.modelName)
                                .font(.system(size: 20))
                            
                        }
                    }
                    Spacer()
                }
                HStack(alignment: .center, spacing: 20) {
                    VStack {
                        Image(systemName: "battery.100percent")
                        Text("100% (780 km)")
                            .lineLimit(1)
                            .font(.system(size: 16))
                        
                    }
                    VStack {
                        Image(systemName: "gearshift.layout.sixspeed")
                        Text(car.transmission)
                            .font(.system(size: 16))
                        
                    }
                    VStack {
                        Image(systemName: "fuelpump")
                        Text(car.fuelType)
                            .font(.system(size: 16))
                        
                    }
                    VStack {
                        Image(systemName: "person")
                        Text("4")
                            .font(.system(size: 16))
                        
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 15)
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("0,22 € | min")
                            .font(.system(size: 20, weight: .bold))
                        Text("1.00 € | Offnen")
                            .font(.system(size: 20))
                    }
                    Spacer()
                    Button {
                        
                    } label: {
                        Text("Tarif")
                    }
                }
                .padding(.bottom, 15)
                Button(action: {
                    isReserved.toggle()
                }) {
                    Text(isReserved ? "Cancel reservation" : "Reserve")
                        .foregroundColor(.white)
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(8) // You can adjust the corner radius as needed
                }
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 20)
            .background(Color.white)
        }
    }
}



struct AsyncImageView: View {
    var url: String?
    
    var body: some View {
        AsyncImage(url: URL(string: url ?? "")) { phase in
            if let image = phase.image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else if phase.error != nil {
                Color.red // Indicates an error.
            } else {
                Color.blue // Acts as a placeholder.
            }
        }
    }
}
