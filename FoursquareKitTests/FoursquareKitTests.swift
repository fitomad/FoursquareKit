//
//  FoursquareKitTests.swift
//  FoursquareKitTests
//
//  Created by Adolfo Vera Blasco on 11/1/17.
//  Copyright © 2017 Adolfo Vera Blasco. All rights reserved.
//

import CoreLocation
import XCTest

@testable import FoursquareKit

class FoursquareKitTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testVenueByLocation()
    {
        let coordenada: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: -3.7079203, longitude: 40.415466)
        let expectation: XCTestExpectation = self.expectation(description: "Venue By Name")
        
        FoursquareClient.sharedClient.venues(close: coordenada, handler: { (resultado: FoursquareResult<[CompactVenue]>) -> (Void) in
            
            switch resultado
            {
                case let .success(result):
                    print("venues: \(result.count)")
                case let .error(reason):
                    print("error: \(reason)")
                case .empty:
                    print("vacio")
            }
            
            expectation.fulfill()
        })
        
        self.waitForExpectations(timeout: 5000, handler: nil)
    }
    
    func testVenueByName()
    {
        let coordenada: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: -3.7079203, longitude: 40.415466)
        let expectation: XCTestExpectation = self.expectation(description: "Venue By Name")
        
        FoursquareClient.sharedClient.venues(named: "Berlin Cabaret", from: coordenada, handler: { (resultado: FoursquareResult<[CompactVenue]>) -> (Void) in
            
            switch resultado
            {
            case let .success(result):
                print("venues: \(result.count)")
                
                for venue in result
                {
                    print("\t> \(venue.name)")
                }
            case let .error(reason):
                print("error: \(reason)")
            case .empty:
                print("vacio")
            }
            
            expectation.fulfill()
        })
        
        self.waitForExpectations(timeout: 5000, handler: nil)
    }
    
    func testVenueByLocationPerformance() {
        // This is an example of a performance test case.
        self.measure
        {
            self.testVenueByLocation()
        }
    }
    
    func testVenueByNamePerformance() {
        // This is an example of a performance test case.
        self.measure
            {
                self.testVenueByName()
        }
    }
    
}
