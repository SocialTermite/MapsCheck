//
//  CarMarkerView.swift
//  MapsCheck
//
//  Created by Konstantin Bondar on 17.02.2024.
//

import SwiftUI

struct CarMarkerView: View {
    var carImageUrl: URL = .init(string: "https://app.check24.de/img/purple.webp")!
    var isReserved: Bool
    @Binding var time: String?
    @Binding var distance: String?
    
    @Binding var isSelected: Bool
    
    private var foregroundColor: Color {
        isReserved ? .blue : .orange
    }
    
    var body: some View {
        ZStack {
//            HorizontalLine()
//                .stroke(Color.black, lineWidth: 2)
//                .frame(height: 1)
//            VerticalLine()
//                .stroke(Color.black, lineWidth: 2)
//                .frame(width: 1, height: 100)
            if isSelected {
                VStack {
                    HStack(spacing: 5) {
                        carImage
                        VStack(alignment: .leading) {
                            Text(time ?? "")
                                .lineLimit(1)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white)
                            Text(distance ?? "")
                                .lineLimit(1)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                    }
                    .padding(5)
                    .background(foregroundColor)
                    .cornerRadius(40)
                    Image(systemName: "arrowtriangle.down.fill")
                        .font(.caption)
                        .foregroundColor(foregroundColor)
                        .offset(y: -6)
                }
                .offset(y: -20)
                
            } else {
                VStack(spacing: 0) {
                    ZStack {
                        Image(systemName: "circle.fill")
                            .font(.title)
                            .foregroundColor(foregroundColor)
                        carImage
                    }
                    Image(systemName: "arrowtriangle.down.fill")
                        .font(.caption)
                        .foregroundColor(foregroundColor)
                        .offset(x: 0, y: -7)
                }
                .offset(y: -14)
            }
            
            
            
            
            
        }
        .onTapGesture {
            isSelected.toggle()
        }
    }
    
    @ViewBuilder
    var carImage: some View {
        Image(systemName: "car.side")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 25, height: 25)
        
            .foregroundColor(.white)
//            .padding(4)
        //                AsyncImage(url: carImageUrl) { phase in
        //                    switch phase {
        //                    case .success(let image):
        //                        image
        //                            .resizable()
        //                            .renderingMode(.template)
        //                            .foregroundColor(.white)
        //                            .aspectRatio(contentMode: .fit)
        //                            .frame(width: 20, height: 20)
        //                            .clipShape(Circle())
        //                    case .failure:
        //
        //                    case .empty:
        //                        ProgressView()
        //                    @unknown default:
        //                        EmptyView()
        //                    }
        //                }
    }
}

#Preview {
    return CarMarkerView(carImageUrl: .init(string: "google.com")!, isReserved: false, time: .constant("6 min"), distance: .constant("3.6 km"), isSelected: .constant(false))
}

struct HorizontalLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        return path
    }
}
struct VerticalLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        return path
    }
}
