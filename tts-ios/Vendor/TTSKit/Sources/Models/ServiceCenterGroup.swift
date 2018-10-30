//
//  ServiceCenterGroup.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 28/03/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation
import CoreLocation

private let kCoordinateFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.decimalSeparator = "."
    return formatter
}()

public struct ServiceCenterGroup: Codable, Equatable {
    
    enum CodingKeys: String, CodingKey {
        case address
        case coordinatesLongitude = "coordinates_longitude"
        case coordinatesLatitude = "coordinates_latitude"
        case services
    }
    
    public let address: String
    
    public let coordinatesLongitude: String
    
    public let coordinatesLatitude: String
    
    public var coordinate: CLLocationCoordinate2D {
        let latitude = kCoordinateFormatter.number(from: coordinatesLatitude)!
        let longitude = kCoordinateFormatter.number(from: coordinatesLongitude)!
        return CLLocationCoordinate2D(latitude: latitude.doubleValue, longitude: longitude.doubleValue)
    }
    
    public let services: [ServiceCenter]
    
    public var autos: [UserAutoLight] {
        return services.reduce(into: [UserAutoLight]()) { $0.append(contentsOf: $1.auto ?? []) }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        address     = try container.decode(String.self, forKey: .address)
        coordinatesLongitude = try container.decode(String.self, forKey: .coordinatesLongitude)
        coordinatesLatitude  = try container.decode(String.self, forKey: .coordinatesLatitude)
        
        // reattach autos to appropriate service centers
        // fixes a bug when all autos are being attached to a single service center in a group
        // see https://redmine.e-legion.com/issues/112730
        var services = try container.decode([ServiceCenter].self, forKey: .services)
        var brands = services.enumerated().reduce(into: [String: (Int, [UserAutoLight])](), { result, pair in pair.element.brandName.flatMap { result[$0] = (pair.offset, []) } })
        services.mapInPlace {
            var service = $0
            guard let autos = service.auto else { return service }
            service.auto = autos.filter { auto in
                guard auto.brand != service.brandName, let (index, autos) = brands[auto.brand] else { return true }
                brands[auto.brand] = (index, autos + [auto])
                return false
            }
            return service
        }
        brands.forEach { pair in
            let (_, (index, autos)) = pair
            guard autos.count > 0 else { return }
            services[index].auto = (services[index].auto ?? []) + autos
        }
        self.services = services
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(address, forKey: .address)
        try container.encode(services, forKey: .services)
        try container.encode(coordinatesLongitude, forKey: .coordinatesLongitude)
        try container.encode(coordinatesLatitude, forKey: .coordinatesLatitude)
    }
    
}

extension Array where Element == ServiceCenterGroup {
    
    public func filter(brand: CarBrand?, city: NamedValue?) -> [Element] {
        guard city != nil || brand != nil else { return self }
        return filter { $0.services.contains(brand: brand, city: city) }
    }
    
}
