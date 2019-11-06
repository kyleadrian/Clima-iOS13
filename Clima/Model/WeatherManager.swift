//
//  SceneDelegate.swift
//  Clima
//
//  Created by Kyle Wiltshire on 11/5/19.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation


// The WeatherManagerDelegate is responsible for making the future delegate aware of the weatherModel when the data is finished being fetched.
protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

// The WeatherManager is responsible for making the API request and transforming the received data into an object that the delegate can receive.
struct WeatherManager {
    let weatherUrl = "https://api.openweathermap.org/data/2.5/weather?appid=4e1a30316c1f82f9d38213652d47508f&units=metric"
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName: String) {
        let urlString = "\(weatherUrl)&q=\(cityName)"
        
        performRequest(with: urlString)
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
           let urlString = "\(weatherUrl)&lat=\(latitude)&lon=\(longitude)"
           
           performRequest(with: urlString)
       }
    
    func performRequest(with urlString: String) {
        // we use if let because URL has an optional intializer type and thus can be nil
        if let url = URL(string: urlString) {
            
            let session = URLSession(configuration: .default)
            // the syntax below is how you write a closure when it's the last parameter in the function.
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    // JSON Decoding
            
                    // we call self here to refer to the WeatherManager function because we are in a closure which is using the session URLSession class.
                    if let weather = self.parseJSON(safeData) {
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            
            task.resume();
        }
    }
    // We set the return value of parseJSON to be an optional WeatherModel so that we can return nil is the try statement fails.
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder() // Must initialize a decoder
        // we use a do try catch statement so that we cater for the asynchronous/ potentially error prone nature of API calls.
        do {
            //Here the type is a "Decodable" type object, which we created in the WeatherData.swift file. We use .self as a way of turning it into a type to satisfy the param req.
            //We store the result in a variable and then we are able to access the properties based on the struct we defined in WeatherData.swift
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id;
            let name = decodedData.name;
            let temp = decodedData.main.temp;
            // With the information from above, we take it and create an instance of our weatherModel.
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            return weather
            
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
        
    }
}
