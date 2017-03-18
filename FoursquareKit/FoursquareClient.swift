//
//  FoursquareClient.swift
//  Sharing
//
//  Created by Adolfo Vera Blasco on 11/1/17.
//  Copyright © 2017 Adolfo Vera Blasco. All rights reserved.
//

import CoreLocation
import Foundation

///
/// Closure donde devolvemos el resultado de lectura del feed
///
/// - Parameter result: Un valor de la enumeracion que informa del 
///     exito o fracaso de la operacion
///
public typealias FoursquareCompletionHandler<T> = (_ result: T) -> (Void)

///
/// All API request will be *returned* here
///
private typealias HttpRequestCompletionHandler = (_ result: HttpResult) -> (Void)

///
/// Foursquare Client
///
public class FoursquareClient
{
    /// Singleton
    public static let sharedClient: FoursquareClient = FoursquareClient()
    /// Configuración Foursquare
    private let clientConfiguration: FoursquareConfig
    
    /// Session HTTP...
    private var httpSession: URLSession!
    /// ...y su configuración
    private var httpConfiguration: URLSessionConfiguration!
    
    /**
 
    */
    private init()
    {
        self.clientConfiguration = FoursquareConfig()
        
        self.httpConfiguration = URLSessionConfiguration.default
        self.httpConfiguration.httpMaximumConnectionsPerHost = 10
        
        let http_queue: OperationQueue = OperationQueue()
        http_queue.maxConcurrentOperationCount = 10
        
        self.httpSession = URLSession(configuration:self.httpConfiguration,
                                      delegate:nil,
                                      delegateQueue:http_queue)
    }
    
    //
    // MARK: - Venue Operations
    
    /**
        Lugares cercanos a una localización dada.
     
        - Parameters:
            - close: Coordenadas donde buscamos
            - inside: Radio de acción de la búsqueda
            - handler: `Closure` donde devolvemos los resultados
    */
    public func venues(close to: CLLocationCoordinate2D, inside radius: Int = 500, handler: @escaping FoursquareCompletionHandler<FoursquareResult<[CompactVenue]>>) -> Void
    {
        let ll: String = "\(to.longitude),\(to.latitude)"
        let uri: String = "\(self.clientConfiguration.baseURL)/venues/search?ll=\(ll)&client_id=\(self.clientConfiguration.clientID)&client_secret=\(self.clientConfiguration.clientSecret)&v=\(self.clientConfiguration.apiVersion)&limit=50&radius=\(radius)"
        
        let url: URL = URL(string: uri)!

        self.processHttp(request: url, httpHandler: { (result: HttpResult) -> (Void) in
            switch result
            {
                case let .success(data):
                    if let resultado = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: Any]
                    {
                        if let responses = resultado?["response"] as? [String: Any],
                           let venues = responses["venues"] as? [[String: Any]],
                           !venues.isEmpty
                        {
                            var compact_venues: [CompactVenue] = [CompactVenue]()

                            for venue in venues
                            {
                                let compact_venue: CompactVenue = CompactVenue(json: venue)

                                compact_venues.append(compact_venue)
                            }

                            handler(FoursquareResult.success(result: compact_venues))
                        }
                    }
                    else
                    {
                        handler(FoursquareResult.empty)
                    }
                case let .requestError(_, message):
                    handler(FoursquareResult.error(reason: message))
                
                case let .connectionError(reason):
                    handler(FoursquareResult.error(reason: reason))
            }
        })
    }
    
    /**
        Lugares por nombre.
     
        - Parameters:
            - named: El nombre del lugar que buscamos
            - from: La ubicación desde la que lanzamos la búsqueda
            - handler: `Closure` donde devolvemos los resultados
    */
    public func venues(named name: String, from location: CLLocationCoordinate2D, handler: @escaping FoursquareCompletionHandler<FoursquareResult<[CompactVenue]>>) -> Void
    {
        let encoded_name: String = name.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!

        let ll: String = "\(location.latitude),\(location.longitude)"
        let uri: String = "\(self.clientConfiguration.baseURL)/venues/search?ll=\(ll)&client_id=\(self.clientConfiguration.clientID)&client_secret=\(self.clientConfiguration.clientSecret)&v=\(self.clientConfiguration.apiVersion)&limit=50&radius=100000&query=\(encoded_name)"
        
        let url: URL = URL(string: uri)!

        self.processHttp(request: url, httpHandler: { (result: HttpResult) -> (Void) in
            switch result
            {
                case let .success(data):
                    do
                    {
                        let resultado: [String: Any]? = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: Any]
                        
                        if let resultado = resultado,
                            let responses = resultado["response"] as? [String: Any],
                            let venues = responses["venues"] as? [[String: Any]],
                            !venues.isEmpty
                        {
                            var compact_venues: [CompactVenue] = [CompactVenue]()
                            
                            for venue in venues
                            {
                                let compact_venue: CompactVenue = CompactVenue(json: venue)
                                
                                compact_venues.append(compact_venue)
                            }
                            
                            handler(FoursquareResult.success(result: compact_venues))
                        }
                    }
                    catch _
                    {
                        handler(FoursquareResult.empty)
                    }
                
                case let .requestError(_, message):
                    handler(FoursquareResult.error(reason: message))
                
                case let .connectionError(reason):
                    handler(FoursquareResult.error(reason: reason))
            }
        })
    }

    //
    // MARK: - Private Methods
    //

    /**
        Peticion a una URL

        - Parameters:
            - url: `URL` solicitada
            - completionHandler: La respuesta a la llamada
    */
    fileprivate func processHttp(request url: URL, httpHandler: @escaping HttpRequestCompletionHandler) -> Void
    {
        var request: URLRequest = URLRequest(url: url)
        request.allHTTPHeaderFields = [
            "Accept-Language" : self.clientConfiguration.apiLocale
        ]

        let data_task: URLSessionDataTask = self.httpSession.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if let error = error
            {
                httpHandler(HttpResult.connectionError(reason: error.localizedDescription))
                return
            }

            guard let data = data, let http_response = response as? HTTPURLResponse else
            {
                httpHandler(HttpResult.connectionError(reason: "No data. No response"))
                return
            }

            switch http_response.statusCode
            {
                case 200:
                    httpHandler(HttpResult.success(data: data))
                    
                default:
                    let code: Int = http_response.statusCode
                    let message: String = HTTPURLResponse.localizedString(forStatusCode: code)

                    httpHandler(HttpResult.requestError(code: code, message: message))
            }
        })

        data_task.resume()
    }
}
