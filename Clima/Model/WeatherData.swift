//
//  File.swift
//  Clima
//
//  Created by Kyle Wiltshire on 11/5/19.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import Foundation

// This struct is created so that we can map the data received from the API call and reference it in the code.
// We need to look at what values and types the data returns to accurately map it.
struct WeatherData: Decodable { // this means that weather data can decode itself from an external representation
    let name: String
    let main: Main
    let weather: [Weather]
}

struct Main: Decodable {
    let temp: Double
}

struct Weather: Decodable {
    let description: String
    let id: Int
}
