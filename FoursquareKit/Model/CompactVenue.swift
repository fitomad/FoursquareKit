//
//  CompactVenue.swift
//  Sharing
//
//  Created by Adolfo Vera Blasco on 11/1/17.
//  Copyright © 2017 Adolfo Vera Blasco. All rights reserved.
//

import CoreLocation
import Foundation

/**
    Un *Venue* de Foursquare.

    Más información en **Venue Search** de la 
    [página](https://developer.foursquare.com/docs/venues/venues) de desarrolladores de Foursquare
*/
public struct CompactVenue
{
    /// Identificador único del sitio en *Foursquare*
    public internal(set) var venueID: String
    /// Nombre del lugar
    public internal(set) var name: String
    /// Si está verficicado o no
    public internal(set) var verified: Bool
    /// La *categoría* en la que se encuadra
    public internal(set) var category: String?
    /// Su ubicación
    public internal(set) var location: CLLocation?
    /// La dirección de manera legible
    public internal(set) var address: String?
    
    /**
        Construimos un *Venue* 
     
        - Parameters:
            - named: Su nombre
            - identifier: El identificador
            - verified: Si está verificado
    */
    internal init(named name: String, identifier venueID: String, verified: Bool)
    {
        self.name = name
        self.venueID = venueID
        self.verified = verified
    }
    
    /**
        Construimos un *Venue* 
     
        - Parameters:
            - named: Su nombre
            - identifier: El identificador
    */
    internal init(named name: String, identifier venueID: String)
    {
        self.init(named: name, identifier: venueID, verified: false)
    }

    /**
        Construimos un *Venue* basado en un documento
        `json` dado por el servidor de **Foursquare API*
     
        - Parameter json: El documento `json`parseado
    */
    internal init(json: [String: Any])
    {
        let venue_name: String = json["name"] as! String
        let venue_id: String = json["id"] as! String
        let verified: Bool = json["verified"] as! Bool

        self.init(named: venue_name, identifier: venue_id, verified: verified)

        if let location = json["location"] as? [String: Any],
           let latitude = location["lat"] as? Double,
           let longitude = location["lng"] as? Double
        {
            let coordinate: CLLocation = CLLocation(latitude: latitude, longitude: longitude)
            self.location = coordinate
        }

        if let location = json["location"] as? [String: Any],
           let address = location["address"] as? String
        {
            self.address = address
        }

        if let categories = json["categories"] as? [[String: Any]], !categories.isEmpty
        {
            if let category = categories[0]["name"] as? String
            {
                self.category = category
            }
        }
    }
}
